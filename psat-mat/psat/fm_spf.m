function fm_spf
% FM_SPF solve standard power flow by means of the NR method
%       and fast decoupled power flow (XB and BX variations)
%       with either a single or distributed slack bus model.
%
% FM_SPF
%
%see the properties of the Settings structure for options.
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    09-Jul-2003
%Version:   1.0.1
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global DAE Pl Mn Lines Line SW PV PQ Bus
global History Theme Fig Settings LIB Snapshot Path File

fm_disp
fm_disp('Newton-Raphson Method for Power Flow Computation')
if Settings.show
  fm_disp(['Data file "',Path.data,File.data,'"'])
end
nodyn = 0;

% these computations are needed only the first time the power flow is run
if ~Settings.init
  % bus type initialization
  fm_ncomp
  if ~Settings.ok, return, end
  % report components parameters to system bases
  if Settings.conv, fm_base, end
  % create the admittance matrix
  Line = build_y(Line);
  % create the FM_CALL FUNCTION
  if Settings.show, fm_disp('Writing file "fm_call" ...',1), end
  fm_wcall;
  fm_dynlf; % indicization of components used in power flow computations
end

% memory allocation for equations and Jacobians
DAE.g = ones(DAE.m,1);
DAE.Gy = sparse(DAE.m,DAE.m);
if (DAE.n~=0)
  DAE.f = ones(DAE.n,1); % differential equations
  DAE.x = ones(DAE.n,1); % state variables
  fm_xfirst;
  DAE.Fx = sparse(DAE.n,DAE.n); % df/dx
  DAE.Fy = sparse(DAE.n,DAE.m); % df/dy
  DAE.Gx = sparse(DAE.m,DAE.n); % dg/dx
else  % no dynamic elements
  nodyn = 1;
  DAE.n = 1;
  DAE.f = 0;
  DAE.x = 0;
  DAE.Fx = 1;
  DAE.Fy = sparse(1,DAE.m);
  DAE.Gx = sparse(DAE.m,1);
end

% check PF solver method
PFmethod = Settings.pfsolver;

ncload = getnum(Mn) + getnum(Pl) + getnum(Lines) + (~nodyn);
if (ncload || Settings.distrsw) && (PFmethod == 2 || PFmethod == 3)
  if ncload
    fm_disp('Fast Decoupled PF cannot be used with dynamic components')
  end
  if Settings.distrsw
    fm_disp('Fast Decoupled PF cannot be used with distributed slack bus model')
  end
  PFmethod = 1; % force using standard NR method
end

switch PFmethod
 case 1, fm_disp('PF solver: Newton-Raphson method')
 case 2, fm_disp('PF solver: XB fast decoupled method')
 case 3, fm_disp('PF solver: BX fast decoupled method')
 case 4, fm_disp('PF solver: Runge-Kutta method')
 case 5, fm_disp('PF solver: Iwamoto method')
 case 6, fm_disp('PF solver: Robust power flow method')
 case 7, fm_disp('PF solver: DC power flow')
end

DAE.lambda = 1;
Jrow = 0;
if Settings.distrsw
  DAE.Fk = sparse(DAE.n,1);
  DAE.Gk = sparse(DAE.m,1);
  Jrow = sparse(1,DAE.n+SW.refbus,1,1,DAE.n+DAE.m+1);
  DAE.kg = 0;
  if ~swgamma(SW,'sum')
    fm_disp('Slack buses have zero power loss participation factor.')
    fm_disp('Single slack bus model will be used')
    Setting.distrsw = 0;
  end
  if totp(SW) == 0
    SW = setpg(totp(PQ)-totp(PV),1);
    fm_disp('Slack buses have zero generated power.')
    fm_disp('P_slack = sum(P_load)-sum(P_gen) will be used.')
    fm_disp('Only PQ loads and PV generators are used.')
    fm_disp('If there are convergence problems, use the single slack bus model.')
  end
  Gkcall(SW);
  Gkcall(PV);
end

switch Settings.distrsw
 case 1
  fm_disp('Distributed slack bus model')
 case 0
  fm_disp('Single slack bus model')
end

iter_max = Settings.lfmit;
convergence = 1;
if iter_max < 2, iter_max = 2; end
iteration = 0;
tol = Settings.lftol;
Settings.error = tol+1;
Settings.iter = 0;
err_max_old = 1e6;
err_vec = [];
alfatry = 1;
alfa = 1; %0.85;
safety = 0.9;
pgrow = -0.2;
pshrnk = -0.25;
robust = 1;
try
  errcon = (5/safety)^(1/pgrow);
catch
  errcon = 1.89e-4;
end

% Graphical settings
fm_status('pf','init',iter_max,{'r'},{'-'},{Theme.color11})
islands(Line)

%  Newton-Raphson routine
t0 = clock;

while (Settings.error > tol) && (iteration <= iter_max) && (alfa > 1e-5)

  if ishandle(Fig.main)
    if ~get(Fig.main,'UserData'), break, end
  end

  switch PFmethod

   case 1 % Standard Newton-Raphson method

    inc = calcInc(nodyn,Jrow);
    DAE.x = DAE.x + inc(1:DAE.n);
    DAE.y = DAE.y + inc(1+DAE.n:DAE.m+DAE.n);
    if Settings.distrsw, DAE.kg = DAE.kg + inc(end); end

   case {2,3} % Fast Decoupled Power Flow

    if ~iteration % initialize variables
      Line = build_b(Line);
      no_sw = Bus.a;
      no_sw(getbus(SW)) = [];
      no_swv = no_sw + Bus.n;
      no_g = Bus.a;
      no_g([getbus(SW); getbus(PV)]) = [];
      Bp = Line.Bp(no_sw,no_sw);
      Bpp = Line.Bpp(no_g,no_g);
      [Lp, Up, Pp] = lu(Bp);
      [Lpp, Upp, Ppp] = lu(Bpp);
      no_g = no_g + Bus.n;
      fm_call('fdpf')
    end

    % P-theta
    da = -(Up\(Lp\(Pp*(DAE.g(no_sw)./DAE.y(no_swv)))));
    DAE.y(no_sw) = DAE.y(no_sw) + da;
    fm_call('fdpf')
    normP = norm(DAE.g,inf);

    % Q-V
    dV = -(Upp\(Lpp\(Ppp*(DAE.g(no_g)./DAE.y(no_g)))));
    DAE.y(no_g) = DAE.y(no_g)+dV;
    fm_call('fdpf')
    normQ = norm(DAE.g,inf);

    inc = [normP; normQ];

    % recompute Bpp if some PV bus has been switched to PQ bus
    if Settings.pv2pq && strmatch('Switch',History.text{end})
      fm_disp('Recomputing Bpp matrix for Fast Decoupled PF')
      no_g = Bus.a;
      no_g([getbus(SW); getbus(PV)]) = [];
      Bpp = Line.Bpp(no_g,no_g);
      [Lpp, Upp, Ppp] = lu(Bpp);
      no_g = no_g + Bus.n;
    end

   case 4 % Runge-Kutta method

    xold = DAE.x;
    yold = DAE.y;
    kold = DAE.kg;

    k1 = alfa*calcInc(nodyn,Jrow);

    Jac = -[DAE.Fx, DAE.Fy; DAE.Gx, DAE.Gy];

    DAE.x = xold + 0.5*k1(1:DAE.n);
    DAE.y = yold + 0.5*k1(1+DAE.n:DAE.m+DAE.n);
    if Settings.distrsw, DAE.kg = kold + 0.5*k1(end); end

    k2 = alfa*calcInc(nodyn,Jrow);

    DAE.x = xold + 0.5*k2(1:DAE.n);
    DAE.y = yold + 0.5*k2(1+DAE.n:DAE.m+DAE.n);
    if Settings.distrsw, DAE.kg = kold + 0.5*k2(end); end

    k3 = alfa*calcInc(nodyn,Jrow);

    DAE.x = xold + k3(1:DAE.n);
    DAE.y = yold + k3(1+DAE.n:DAE.m+DAE.n);
    if Settings.distrsw, DAE.kg = kold + k3(end); end

    k4 = alfa*calcInc(nodyn,Jrow);

    % compute RK4 increment of variables
    inc = (k1+2*(k2+k3)+k4)/6;

    % to estimate RK error, use the RK2:Dy and RK4:Dy.
    yerr = max(abs(abs(k2)-abs(inc)));
    if yerr > 0.01
      alfa = max(0.985*alfa,0.75);
    else
      alfa = min(1.015*alfa,0.75);
    end

    DAE.x = xold + inc(1:DAE.n);
    DAE.y = yold + inc(1+DAE.n:DAE.m+DAE.n);
    if Settings.distrsw, DAE.kg = kold + inc(end); end

   case 5 % Iwamoto method

    xold = DAE.x;
    yold = DAE.y;
    kold = DAE.kg;

    inc = calcInc(nodyn,Jrow);

    vec_a = -[DAE.Fx, DAE.Fy; DAE.Gx, DAE.Gy]*inc;
    vec_b = -vec_a;
    DAE.x = inc(1:DAE.n);
    DAE.y = inc(1+DAE.n:DAE.m+DAE.n);

    if Settings.distrsw
      DAE.kg = inc(end);
      fm_call('kgpf');
      if nodyn, DAE.Fx = 1; end
      vec_c = -[DAE.f; DAE.g; DAE.y(SW.refbus)];
    else
      refreshJac;
      fm_call('l');
      refreshGen(nodyn);
      vec_c = -[DAE.f; DAE.g];
    end

    g0 = (vec_a')*vec_b;
    g1 = sum(vec_b.*vec_b + 2*vec_a.*vec_c);
    g2 = 3*(vec_b')*vec_c;
    g3 = 2*(vec_c')*vec_c;

    % mu = fsolve(@(x) g0 + x*(g1 + x*(g2 + x*g3)), 1.0);

    % Cardan's formula
    pp = -g2/3/g3;
    qq = pp^3 + (g2*g1-3*g3*g0)/6/g3/g3;
    rr = g1/3/g3;

    mu = (qq+sqrt(qq*qq+(rr-pp*pp)^3))^(1/3) + ...
         (qq-sqrt(qq*qq+(rr-pp*pp)^3))^(1/3) + pp;

    mu = min(abs(mu),0.75);

    DAE.x = xold + mu*inc(1:DAE.n);
    DAE.y = yold + mu*inc(1+DAE.n:DAE.n+DAE.m);
    if Settings.distrsw, DAE.kg = kold + mu*inc(end); end

   case 6 % simple robust power flow method

    inc = robust*calcInc(nodyn,Jrow);
    Settings.error = max(abs(inc));

    if Settings.error > 1.5*err_max_old && iteration
      robust = 0.25*robust;
      if robust < tol
        fm_disp('The otpimal multiplier is too small.')
        iteration = iter_max+1;
        break
      end
    else
      DAE.x = DAE.x + inc(1:DAE.n);
      DAE.y = DAE.y + inc(1+DAE.n:DAE.m+DAE.n);
      if Settings.distrsw, DAE.kg = DAE.kg + inc(end); end
      err_max_old = Settings.error;
      robust = 1;
    end

  end

  iteration = iteration + 1;
  Settings.error = max(abs(inc));
  Settings.iter = iteration;
  err_vec(iteration) = Settings.error;

  if Settings.error < 1e-2 && PFmethod > 3 && Settings.switch2nr
    fm_disp('Switch to standard Newton-Raphson method.')
    PFmethod = 1;
  end

  fm_status('pf','update',[iteration, Settings.error],iteration)

  if Settings.show
    if Settings.error == Inf, Settings.error = 1e3; end
    fm_disp(['Iteration = ', num2str(iteration), ...
             '     Maximum Convergency Error = ', ...
             num2str(Settings.error)],1)
  end

  % stop if the error increases too much
  if iteration > 4
    if err_vec(iteration) > 1000*err_vec(1)
      fm_disp('The error is increasing too much.')
      fm_disp('Convergence is likely not reachable.')
      convergence = 0;
      break
    end
  end

end

Settings.lftime = etime(clock,t0);
if iteration > iter_max
  fm_disp(['Reached maximum number of iteration of NR routine without ' ...
           'convergence'],2)
  convergence = 0;
end

% Total power injections and consumptions at network buses

% Pl and Ql computation (shunts only)
DAE.g = zeros(DAE.m,1);
fm_call('load0');
Bus.Pl = DAE.g(Bus.a);
Bus.Ql = DAE.g(Bus.v);

%Pg and Qg computation
fm_call('gen0');
Bus.Pg = DAE.g(Bus.a);
Bus.Qg = DAE.g(Bus.v);
if ~Settings.distrsw
  SW = setpg(SW,'all',Bus.Pg(SW.bus));
end

% adjust powers in case of PQ generators
adjgen(PQ)

% memory allocation for dynamic variables & state variables indicization
if nodyn == 1; DAE.x = []; DAE.f = []; DAE.n = 0; end
DAE.npf = DAE.n;
m_old = DAE.m;
fm_dynidx;

% rebuild algebraic variables and vectors
m_diff = DAE.m-m_old;
if m_diff
  DAE.y = [DAE.y;zeros(m_diff,1)];
  DAE.g = [DAE.g;zeros(m_diff,1)];
  DAE.Gy = sparse(DAE.m,DAE.m);
end

% rebuild state variables and vectors
if DAE.n ~= 0
  DAE.f = [DAE.f; ones(DAE.n-DAE.npf,1)];  % differential equations
  DAE.x = [DAE.x; ones(DAE.n-DAE.npf,1)];  % state variables
  DAE.Fx = sparse(DAE.n,DAE.n); % state Jacobian df/dx
  DAE.Fy = sparse(DAE.n,DAE.m); % state Jacobian df/dy
  DAE.Gx = sparse(DAE.m,DAE.n); % algebraic Jacobian dg/dx
end

%  build cell arrays of variable names
fm_idx(1)
if (Settings.vs == 1), fm_idx(2), end

% initializations of state variables and components
if Settings.static
  fm_disp('* * * Dynamic components are not initialized * * *')
end
if convergence
  Settings.init = 1;
else
  Settings.init = -1;
end
fm_rmgen(-1); % initialize function for removing static generators
fm_call('0'); % compute initial state variables

% power flow result visualization
fm_disp(['Power Flow completed in ',num2str(Settings.lftime),' s'])
if Settings.showlf == 1 || ishandle(Fig.stat)
  fm_stat;
else
  if Settings.beep, beep, end
end
if ishandle(Fig.threed), fm_threed('update'), end

% initialization of all equations & Jacobians
refreshJac
fm_call('i');

% build structure "Snapshot"
if isempty(Settings.t0) && ishandle(Fig.main)
  hdl = findobj(Fig.main,'Tag','EditText3');
  Settings.t0 = str2num(get(hdl,'String'));
end

if ~Settings.locksnap && Bus.n <= 5000 && DAE.n < 5000
  Snapshot = struct( ...
      'name','Power Flow Results', ...
      'time',Settings.t0, ...
      'y',DAE.y, ...
      'x',DAE.x,...
      'Ybus',Line.Y, ...
      'Pg',Bus.Pg, ...
      'Qg',Bus.Qg, ...
      'Pl',Bus.Pl, ...
      'Ql',Bus.Ql, ...
      'Gy',DAE.Gy, ...
      'Fx',DAE.Fx, ...
      'Fy',DAE.Fy, ...
      'Gx',DAE.Gx, ...
      'Ploss',sum(Bus.Pg)-sum(Bus.Pl), ...
      'Qloss',sum(Bus.Qg)-sum(Bus.Ql), ...
      'it',1);
else
  if Bus.n > 5000
    fm_disp(['Snapshots are disabled for networks with more than 5000 ' ...
             'buses.'])
  end
  if DAE.n > 5000
    fm_disp(['Snapshots are disabled for networks with more than 5000 ' ...
             'state variables.'])
  end
end

fm_status('pf','close')

LIB.selbus = min(LIB.selbus,Bus.n);
if ishandle(Fig.lib),
  set(findobj(Fig.lib,'Tag','Listbox1'), ...
      'String',Bus.names, ...
      'Value',LIB.selbus);
end


% -----------------------------------------------
function refreshJac

global DAE

DAE.g = zeros(DAE.m,1);

% -----------------------------------------------
function refreshGen(nodyn)

global DAE SW PV

if nodyn, DAE.Fx = 1; end

Fxcall(SW,'full')
Fxcall(PV)

% -----------------------------------------------
function inc = calcInc(nodyn,Jrow)

global DAE Settings SW PV

DAE.g = zeros(DAE.m,1);

if Settings.distrsw % distributed slack bus

  fm_call('kgpf');
  if nodyn, DAE.Fx = 1; end
  inc = -[DAE.Fx,DAE.Fy,DAE.Fk;DAE.Gx,DAE.Gy,DAE.Gk;Jrow]\ ...
        [DAE.f; DAE.g; DAE.y(SW.refbus)];

else % single slack bus

  fm_call('l');
  if nodyn, DAE.Fx = 1; end
  Fxcall(SW,'full')
  Fxcall(PV)
  inc = -[DAE.Fx, DAE.Fy; DAE.Gx, DAE.Gy]\[DAE.f; DAE.g];

end