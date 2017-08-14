function lambda_crit = fm_cpf(fun)
% FM_CPF continuation power flow routines for computing nose curves
%        and determining critical points (saddle-node bifurcations)
%
% [LAMBDAC] = FM_CPF
%
%       LAMBDAC: loading paramter at critical or limit point
%
%see also CPF structure and FM_CPFFIG
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    16-Sep-2003
%Version:   1.0.1
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

fm_var

global Settings

if ~autorun('Continuation Power Flow',0), return, end

lambda_crit = [];
lastwarn('')

%  Settings
if CPF.ilim
  ilim = CPF.flow;
else
  ilim = 0;
end
type = double(~CPF.sbus);
if type && SW.n == 1 && Supply.n == 1
  if Supply.bus ~= SW.bus
    fm_disp(' * * ')
    fm_disp('Only one Supply found. Single slack bus model will be used.')
    type = 0;
  end
end

stop = CPF.type - 1;
vlim = CPF.vlim;
qlim = CPF.qlim;
perp = ~(CPF.method - 1);
hopf = 1;

if strcmp(fun,'atc') || strcmp(fun,'gams')
  one = 1;
else
  one = 0;
end

%if PV.n+SW.n == 1, type = 0; end

if CPF.show
  fm_disp
  if type
    fm_disp('Continuation Power Flow - Distribuited Slack Bus')
  else
    fm_disp('Continuation Power Flow - Single Slack Bus')
  end
  fm_disp(['Data file "',Path.data,File.data,'"'])
  fm_disp
  if perp
    fm_disp('Corrector Method:         Perpendicular Intersection')
  else
    fm_disp('Corrector Method:         Local Parametrization')
  end
  if vlim
    fm_disp('Check Voltage Limits:     Yes')
  else
    fm_disp('Check Voltage Limits:     No')
  end
  if qlim
    fm_disp('Check Generator Q Limits: Yes')
  else
    fm_disp('Check Generator Q Limits: No')
  end
  if ilim
    fm_disp('Check Flow Limits:        Yes')
  else
    fm_disp('Check Flow Limits:        No')
  end
  fm_disp
end

% Initializations of vectors and matrices
% ----------------------------------------------------------------------

% disable conversion to impedance for PQ loads
forcepq = Settings.forcepq;
Settings.forcepq = 1;

nodyn = 0;

% initialization of the state vector and Jacobian matices
if DAE.n > 0
  DAE.f = ones(DAE.n,1);  % state variable time derivatives
  fm_xfirst;
  DAE.Fx = sparse(DAE.n,DAE.n); % Dx(f)
  DAE.Fy = sparse(DAE.n,DAE.m); % Dy(f)
  DAE.Gx = sparse(DAE.m,DAE.n); % Dx(g)
  DAE.Fl = sparse(DAE.n,1);
  DAE.Fk = sparse(DAE.n,1);
else  % no dynamic components
  nodyn = 1;
  DAE.n = 1;
  DAE.f = 0;
  DAE.x = 0;
  DAE.Fx = 1;
  DAE.Fy = sparse(1,DAE.m);
  DAE.Gx = sparse(DAE.m,1);
  DAE.Fl = 0;
  DAE.Fk = 0;
end

PV2PQ = Settings.pv2pq;
noDem = 0;
noSup = 0;
sp = ' * ';

Settings.pv2pq = 0;

Imax = getflowmax(Line,ilim);
switch ilim
  case 1, fw = 'I ';
  case 2, fw = 'P ';
  case 3, fw = 'S ';
end

if CPF.areaannualgrowth, growth(Areas,'area'), end
if CPF.regionannualgrowth, growth(Regions,'region'), end

% if no Demand.con is found, the load direction
% is assumed to be the one of the PQ load
if Demand.n
  no_dpq = findzero(Demand);
  if ~isempty(no_dpq),
    fm_disp
    for i = 1:length(no_dpq)
      fm_disp(['No power direction found in "Demand.con" for Bus ', ...
        Bus.names{Demand.bus(no_dpq(i))}])
    end
    fm_disp('Continuation load flow routine may have convergence problems.',2)
    fm_disp
  end
else
  noDem = 1;
  idx = findpos(PQ);
  Demand = add(Demand,dmdata(PQ,idx));
  PQ = pqzero(PQ,idx);
end
PQgen = pqzero(PQgen,'all');

% if no Supply.con is found, the load direction
% is assumed to be the one of the PV or the SW generator
if Supply.n && ~Syn.n
  no_sp = findzero(Supply);
  if ~isempty(no_sp),
    fm_disp
    if length(no_sp) == Supply.n
      fm_disp(['No power directions found in "Supply.con" for all buses.'])
      if noDem
        fm_disp('Supply data will be ignored.')
        noSup = 1;
        Supply = remove(Supply,[1:Supply.n]);
        if qlim && type, SW = move2sup(SW); end
        %SW = move2sup(SW);
        %PV = move2sup(PV);
      else
        fm_disp('Remove "Supply" components or set power directions.')
        fm_disp('Continuation power flow interrupted',2)
        if CPF.show
          set(Fig.main,'Pointer','arrow');
        end
        return
      end
    else
      for i = 1:length(no_sp)
        fm_disp(['No power direction found in "Supply.con" for Bus ', ...
          Bus.names{Supply.bus(no_sp(i))}])
      end
      fm_disp('Continuation power flow routine may have convergence problems.',2)
      fm_disp
    end
  end
else
  noSup = 1;
  Supply = remove(Supply,[1:Supply.n]);
  if qlim && type, SW = move2sup(SW); end
end

% Newton-Raphson routine settings
iter_max = Settings.lfmit;
iterazione = 0;
tol =  CPF.tolc;
tolf = CPF.tolf;
tolv = CPF.tolv;
proceed = 1;
sigma_corr = 1;
if DAE.n == 0, DAE.n = 1; end

Kjac = sparse(1,DAE.m+DAE.n+2);
Ljac = sparse(1,DAE.m+DAE.n+2);
kjac = sparse(1,DAE.m+DAE.n+1);
Kjac(1,DAE.n+SW.refbus) = 1;
kjac(1,DAE.n+SW.refbus) = 1;

% chose a PQ to display the CPF progress in the main window
PQidx = pqdisplay(PQ);
fm_snap('cleansnap')

if ~PQidx % absence of PQ buses
  PQidx = pqdisplay(Demand);
  if ~PQidx
    if ~perp
      perp = 1;
      fm_disp('* * * Switch to perpendicular intersection * * * ')
    end
    PQidx = 1;
  end
end

PQvdx = PQidx + Bus.n;

% ---------------------------------------------------------------------
% Continuation Power Flow Routine
% ---------------------------------------------------------------------

tic

fm_status('cpf','init',12,{'m'},{'-'},{Theme.color11},[0 1.2])

l_vect = [];

lambda = CPF.linit;
DAE.lambda = lambda;
lambda_crit = CPF.linit;
kg = 0;
lambda_old = -1;
Jsign = 0;
Jsign_old = 0;
Sflag = 1;
ksign = 1;
Qmax_idx = [];
Qmin_idx = [];
Vmax_idx = [];
Vmin_idx = [];
Iij_idx = [];
Iji_idx = [];
Iij = ones(Line.n,1);
Iji = ones(Line.n,1);
Qswmax_idx = [];
Qswmin_idx = [];

pqlim(PQ,vlim,0,0,0);
fm_out(0,0,0)
if nodyn
  DAE.Fx = 1;
  Varout.idx = Varout.idx+1;
end
fm_out(1,0,0)

% initial Jacobian Gk
DAE.Gk = sparse(DAE.m,1);
if type, Gkcall(Supply), end
if type, Gkcall(PV), end
Gkcall(SW)

DAE.kg = 0;
Gycall(Line)
if noSup
  Gyreactive(PV)
else
  Gycall(PV)
end
Gyreactive(SW)

% First predictor step
% ---------------------------------------------------------------

Jsign = 1;
count_qmin = 0;
kqmin = 1;
d_lambda = 0;
lambda_old = CPF.linit;
inc = zeros(DAE.n+DAE.m+2,1);
Ljac(end) = 1;

% critical point
y_crit = DAE.y;
x_crit = DAE.x;
k_crit = kg;
l_crit = lambda;

while 1

  cpfmsg = [];

  % corrector step
  % ---------------------------------------------------------------

  lim_hb = 0;
  lim_lib = 0;
  y_old = DAE.y;
  x_old = DAE.x;
  kg_old = kg;
  lambda_old = lambda;
  corrector = 1;
  if PV.n, inc(DAE.n+getbus(PV,'v')) = 0; end
  if SW.n, inc(DAE.n+getbus(SW,'v')) = 0; end

  while corrector

    if ishandle(Fig.main)
      if ~get(Fig.main,'UserData'), break, end
    end

    iter_corr = 0;
    Settings.error = tol+1;

    while Settings.error > tol

      if (iter_corr > iter_max), break, end
      if ishandle(Fig.main)
        if ~get(Fig.main,'UserData'), break, end
      end

      DAE.lambda = lambda;
      DAE.Fl = sparse(DAE.n,1);
      DAE.Gl = sparse(DAE.m,1);
      DAE.Gk = sparse(DAE.m,1);

      % call component functions

      fm_call('kg')

      if nodyn, DAE.Fx = 1; end

      gcall(PQgen)
      glambda(Demand,lambda)
      glambda(Supply,lambda,type*kg)
      glambda(Syn,lambda,kg)
      glambda(Tg,lambda,kg)

      Glcall(Pl)
      Glcall(Mn)
      Glcall(Demand)
      Glcall(Supply)
      Glcall(Syn)
      Glcall(Tg)
      Glcall(Wind)
      Flcall(Ind)

      if type, Gkcall(Supply), end

      if noSup
        glambda(PV,lambda,type*kg)
        glambda(SW,lambda,kg)
        greactive(PV)
        if type, Gkcall(PV), end
        Glcall(PV)
        Gyreactive(PV)
        Glcall(SW)
      else
        gcall(PV);
        Gycall(PV)
        glambda(SW,1,kg)
      end

      Glreac(PV)
      Fxcall(PV)
      Gkcall(SW)
      greactive(SW)
      Gyreactive(SW)
      Glreac(SW)
      Fxcall(SW,'onlyq')

      if perp*iterazione
        Cinc = sigma_corr*inc;
        %cont_eq = Cinc'*([DAE.x;DAE.y;kg;lambda]- ...
        %  [x_old; y_old; kg_old; lambda_old]-Cinc);
        Cinc(end-1) = 0;
        cont_eq = Cinc'*([DAE.x;DAE.y;0;lambda]- ...
                         [x_old; y_old; 0; lambda_old]-Cinc);
        inc_corr = -[DAE.Fx, DAE.Fy, DAE.Fk, DAE.Fl; DAE.Gx, DAE.Gy, ...
                     DAE.Gk, DAE.Gl; Cinc'; Kjac]\[DAE.f; DAE.g; ...
                            cont_eq; DAE.y(SW.refbus)];
        if strcmp(lastwarn,['Matrix is singular to working ' ...
                            'precision.'])
          Cinc(end) = 0;
          cont_eq = Cinc'*([DAE.x;DAE.y;0;0]- ...
                           [x_old; y_old; 0; 0]-Cinc);
          inc_corr = -[DAE.Fx, DAE.Fy, DAE.Fk, DAE.Fl; DAE.Gx, DAE.Gy, ...
                       DAE.Gk, DAE.Gl; Cinc'; Kjac]\[DAE.f; DAE.g; ...
                              cont_eq; DAE.y(SW.refbus)];
        end
      else
        if iterazione
          cont_eq = DAE.y(PQvdx)-sigma_corr*inc(PQvdx+DAE.n)-y_old(PQvdx);
        else
          cont_eq = lambda - sigma_corr*d_lambda - lambda_old;
        end
        inc_corr = -[DAE.Fx, DAE.Fy, DAE.Fk, DAE.Fl; DAE.Gx, DAE.Gy, ...
          DAE.Gk, DAE.Gl; Ljac; Kjac]\[DAE.f; DAE.g; ...
          cont_eq; DAE.y(SW.refbus)];
      end

      DAE.x = DAE.x + inc_corr(1:DAE.n);
      DAE.y = DAE.y + inc_corr(1+DAE.n:DAE.m+DAE.n);
      kg = kg + inc_corr(end-1);

      %[xxx,iii] = max(abs(inc_corr));
      %disp([xxx,iii])

      lambda = lambda + inc_corr(end);
      iter_corr = iter_corr + 1;
      Settings.error = max(abs(inc_corr));
    end

    % Generator reactive power computations
    if qlim
      DAE.g = zeros(DAE.m,1);
      fm_call('load');
      glambda(Demand,lambda)
      Bus.Ql = DAE.g(Bus.v);
      fm_call('gen');
      glambda(Demand,lambda)
      Bus.Qg = DAE.g(Bus.v);
      DAE.g = zeros(DAE.m,1);
      [Qmax_idx,Qmin_idx] = pvlim(PV);
      [Qswmax_idx,Qswmin_idx] = swlim(SW);
      if ~kqmin
        Qmin_idx = [];
        Qswmin_idx = [];
      end
    end

    [PQ,lim_v] = pqlim(PQ,vlim,sp,lambda,one);

    if lim_v
      sigma_corr = 1;
      proceed = 1;
      if stop > 1
        sigma_corr = -1;
        break
      end
    end

    if ilim
      [Fij,Fji] = flows(Line,ilim);
      Iij_idx = find(Fij > Imax & Iij);
      Iji_idx = find(Fji > Imax & Iji);
    end

    % determination of the initial loading factor in case
    % of infeasible underexcitation of generator at zero
    % load condition
    if ~iterazione && qlim && ~isempty(Qmin_idx) && count_qmin <= 5
      count_qmin = count_qmin+1;
      if count_qmin > 5
        fm_disp([sp,'There are generator Qmin limit violations at ' ...
          'the initial point.'])
        fm_disp([sp,'Generator Qmin limits will be disabled.'])
        kqmin = 0;
        lambda_old = CPF.linit;
        lambda = CPF.linit;
        sigma_corr = 1;
      else
        lambda_old = lambda_old + d_lambda;
        fm_disp([sp,'Initial loading parameter changed to ', ...
          fvar(lambda_old-one,4)])
      end
      proceed = 0;
      break
    end

    % Check for Hopf Bifurcations
    if DAE.n >= 2 && CPF.hopf && hopf
      As = DAE.Fx-DAE.Fy*(DAE.Gy\DAE.Gx);
      if DAE.n > 100
        opt.disp = 0;
        auto = eigs(As,20,'SR',opt);
      else
        auto = eig(full(As));
      end
      auto = round(auto/Settings.lftol)*Settings.lftol;
      hopf_idx = find(real(auto) > 0);
      if ~isempty(hopf_idx)
        hopf = 0;
        hopf_idx = find(abs(imag(auto(hopf_idx))) > 1e-5);
        if ~isempty(hopf_idx)
          lim_hb = 1;
          fm_disp([sp,'Hopf bifurcation encountered.'])
        end
        if stop
          sigma_corr = -1;
          break
        end
      end
    end

    if ~isempty(Iij_idx) && ilim
      Iij_idx = Iij_idx(1);
      Iij(Iij_idx) = 0;
      fm_disp([sp,fw,'from bus #',fvar(Line.fr(Iij_idx),4), ...
        ' to bus #',fvar(Line.to(Iij_idx),4), ...
        ' reached I_max at lambda = ',fvar(lambda-one,9)],1)
      sigma_corr = 1;
      proceed = 1;
      if stop > 1
        proceed = 1;
        sigma_corr = -1;
        break
      end
    end

    if ~isempty(Iji_idx) && ilim
      Iji_idx = Iji_idx(1);
      Iji(Iji_idx) = 0;
      fm_disp([sp,fw,'from bus #',fvar(Line.to(Iji_idx),4), ...
        ' to bus #',fvar(Line.fr(Iji_idx),4), ...
        ' reached I_max at lambda = ',fvar(lambda-one,9)],1)
      sigma_corr = 1;
      proceed = 1;
      if stop > 1
        proceed = 1;
        sigma_corr = -1;
        break
      end
    end

    if lambda < CPF.linit
      cpfmsg = [sp,'lambda is lower than initial value'];
      if iterazione > 5
        proceed = 0;
        break
      end
    end

    if abs(lambda-lambda_old) > 5*abs(d_lambda) && perp && iterazione ...
          && ~Hvdc.n
      fm_disp([sp,'corrector solution is too far from predictor value'])
      proceed = 0;
      break
    end
    if lambda > lambda_old && lambda < max(l_vect) && ~Hvdc.n
      fm_disp([sp,'corrector goes back increasing lambda'])
      proceed = 0;
      break
    end

    lim_q = (~isempty(Qmax_idx) || ~isempty(Qmin_idx) || ...
      (~isempty(Qswmax_idx) || ~isempty(Qswmin_idx))*type) && qlim;
    lim_i = (~isempty(Iij_idx) || ~isempty(Iji_idx)) && ilim;

    anylimit = (lim_q || lim_v || lim_i) && CPF.stepcut;

    if iter_corr > iter_max % no convergence
      if lambda_old < 0.5*max(l_vect)
        fm_disp([sp,'Convergence problems in the unstable curve'])
        lambda = -1;
        proceed = 1;
        break
      end
      if sigma_corr < 1e-3
        proceed = 1;
        break
      end
      if CPF.show
        fm_disp([sp,'Max # of iters. at corrector step.'])
        fm_disp([sp,'Reduced Variable Increments in ', ...
          'Corrector Step ', num2str(0.5*sigma_corr)])
      end
      cpfmsg = [sp,'Reached maximum number of iterations ', ...
        'for corrector step.'];
      proceed = 0;
      break
    elseif anylimit && sigma_corr > 0.11
      proceed = 0;
      break
    elseif lim_q
      if ~isempty(Qmax_idx)
        PQgen = add(PQgen,pqdata(PV,Qmax_idx(1),'qmax',sp,lambda,one,noSup));
        if noSup,
          PV = move2sup(PV,Qmax_idx(1));
        else
          PV = remove(PV,Qmax_idx(1));
        end
      elseif ~isempty(Qmin_idx)
        PQgen = add(PQgen,pqdata(PV,Qmin_idx(1),'qmin',sp,lambda,one,noSup));
        if noSup
          PV = move2sup(PV,Qmin_idx(1));
        else
          PV = remove(PV,Qmin_idx(1));
        end
      elseif ~isempty(Qswmax_idx)
        PQgen = add(PQgen,pqdata(SW,Qswmax_idx(1),'qmax',sp,lambda,one));
        SW = remove(SW,Qswmax_idx(1));
      elseif ~isempty(Qswmin_idx)
        PQgen = add(PQgen,pqdata(SW,Qswmin_idx(1),'qmin',sp,lambda,one));
        SW = remove(SW,Qswmin_idx(1));
      end
      lim_lib = 1;
      Qmax_idx = [];
      Qmin_idx = [];
      Qswmax_idx = [];
      Qswmin_idx = [];
      if ~iterazione
        d_lambda = 0;
        lambda_old = CPF.linit;
        lambda = CPF.linit;
        if perp
          inc(end) = 1e-5;
        else
          Ljac(end) = 1;
        end
      else
        lambda = lambda_old;
        sigma_corr = 1;
        proceed = 0;
        break
      end
    else
      proceed = 1;
      sigma_corr = 1;
      if stop && ksign < 0,
        if lim_lib
          fm_disp([sp,'Saddle-Node Bifurcation encountered.'])
        else
          fm_disp([sp,'Limit-Induced Bifurcation encountered.'])
        end
        sigma_corr = -1;
      end
      break
    end
  end

  switch proceed
   case 1
    if lambda < 0 && iterazione > 1
      % needed to make consistent the last snapshot
      fm_call('kg')
      gcall(PQgen)
      fm_disp([sp,'lambda < 0 at iteration ',num2str(iterazione)])
      break
    end
    l_vect = [l_vect; lambda];

    if CPF.show
      fm_disp(['Point = ',fvar(iterazione+1,5),'lambda =', ...
        fvar(lambda-one,9), '    kg =',fvar(kg,9)],1)
    end
    iterazione = iterazione + 1;

    fm_out(2,lambda,iterazione)

    fm_status('cpf','update',[lambda, DAE.y(PQvdx)],iterazione)

    if sigma_corr < tol, break, end
    sigma_corr = 1;
    if lambda > lambda_old
      y_crit = DAE.y;
      x_crit = DAE.x;
      k_crit = kg;
      l_crit = lambda;
    end
   case 0
    DAE.y = y_old;
    DAE.x = x_old;
    if abs(lambda-CPF.linit) < 0.001 && ...
          abs(lambda-lambda_old) <= 10*abs(d_lambda) && ...
          iterazione > 1
      fm_disp([sp,'Reached initial lambda.'])
      % needed to make consistent the last snapshot
      fm_call('kg')
      gcall(PQgen)
      break
    end
    kg = kg_old;
    lambda = lambda_old;
    sigma_corr = 0.1*sigma_corr;
    if sigma_corr < tol,
      if ~isempty(cpfmsg)
        fm_disp(cpfmsg)
      end
      if iterazione == 0
        fm_disp([sp,'Infeasible initial loading condition.'])
      else
        fm_disp([sp,'Convergence problem encountered.'])
      end
      break
    end
  end

  % stop routine
  % --------------------------------------------------------------

  if iterazione >= CPF.nump && ~strcmp(fun,'gams')
    fm_disp([sp,'Reached maximum number of points.'])
    break
  end
  if ishandle(Fig.main)
    if ~get(Fig.main,'UserData'), break, end
  end

  % predictor step
  % --------------------------------------------------------------

  DAE.lambda = lambda;

  % update Jacobians
  fm_call('kg')

  if nodyn, DAE.Fx = 1; end

  if noSup
    Gyreactive(PV)
  else
    Gycall(PV);
  end
  Gyreactive(SW)

  if (DAE.m+DAE.n) > 500
    [L,U,P] = luinc([DAE.Fx,DAE.Fy,DAE.Fk;DAE.Gx,DAE.Gy,DAE.Gk;kjac],1e-6);
  else
    [L,U,P] = lu([DAE.Fx,DAE.Fy,DAE.Fk;DAE.Gx,DAE.Gy,DAE.Gk;kjac]);
  end
  dz_dl = -U\(L\(P*[DAE.Fl;DAE.Gl;0]));
  Jsign_old = Jsign;
  Jsign = signperm(P)*sign(prod(diag(U)));

  if lim_lib
    fm_snap('assignsnap','new','LIB',lambda)
  elseif lim_hb
    fm_snap('assignsnap','new','HB',lambda)
  end

  if iterazione == 1
    if noDem && lambda == 1
      fm_snap('assignsnap','start','OP',lambda)
    elseif ~noDem && lambda == 0
      fm_snap('assignsnap','start','OP',lambda)
    else
      fm_snap('assignsnap','start','Init',lambda)
    end
  end

  if Jsign ~= Jsign_old && Sflag && iterazione > 1
    ksign = -1;
    Sflag = 0;
    if ~lim_lib, fm_snap('assignsnap','new','SNB',lambda), end
  end

  Norm = norm(dz_dl,2);
  if Norm == 0, Norm = 1; end
  d_lambda = ksign*CPF.step/Norm;
  d_lambda = min(d_lambda,0.35);
  d_lambda = max(d_lambda,-0.35);
  if ksign > 0, d_lambda = max(d_lambda,0); end
  if ksign < 0, d_lambda = min(d_lambda,0); end
  d_z = d_lambda*dz_dl;
  inc = [d_z; d_lambda];
  if ~perp && iterazione
    a = inc(DAE.n+PQvdx);
    a = min(a,0.025);
    a = max(a,-0.025);
    inc(DAE.n+PQvdx) = a;
    Ljac(end) = 0;
    Ljac(DAE.n+PQvdx) = 1;
  end

end

fm_out(3,0,iterazione)
fm_snap('assignsnap','new','End',Varout.t(end))
[lambda_crit, idx_crit] = max(Varout.t);
if isnan(lambda_crit), lambda_crit = lambda; end
if isempty(lambda_crit), lambda_crit = lambda; end
if CPF.show
  fm_disp([sp,'Maximum Loading Parameter lambda_max = ', ...
    fvar(lambda_crit-one,9)],1)
end

%  Visualization of results
% --------------------------------------------------------------
if nodyn
  DAE.n = 0;
  Varout.idx = Varout.idx-1;
end
Settings.lftime = toc;
Settings.iter = iterazione;

DAE.y = y_crit;
DAE.x = x_crit;
kg = k_crit;
lambda = l_crit;

if ~isempty(DAE.y)
  if CPF.show
    fm_disp(['Continuation Power Flow completed in ', ...
      num2str(toc),' s'],1);
  end
  DAE.g = zeros(DAE.m,1);
  fm_call('load');
  glambda(Demand,lambda)
  % load powers
  Bus.Pl = DAE.g(Bus.a);
  Bus.Ql = DAE.g(Bus.v);
  % gen powers
  fm_call('gen')
  Bus.Qg = DAE.g(Bus.a);
  Bus.Pg = DAE.g(Bus.v);
  DAE.g = Settings.error*ones(DAE.m,1);
  if (Settings.showlf == 1 && CPF.show) || ishandle(Fig.stat)
    SDbus = [Supply.bus;Demand.bus];
    report = cell(1,1);
    report{1,1} = ['Lambda_max = ', fvar(lambda_crit,9)];
    %for i = 1:length(dl_dp)
    %  report{2+i,1} = ['d lambda / d P ', ...
    %		       Bus.names{SDbus(i)},' = ', ...
    %		       fvar(dl_dp(i),9)];
    %end
    fm_stat(report);
  end
  if CPF.show && ishandle(Fig.plot)
    fm_plotfig
  end
end

%  Reset of SW, PV and PQ structures
Settings.forcepq = forcepq;
%PQgen = restore(PQgen,0);
%PQ = restore(PQ);
%PV = restore(PV);
%SW = restore(SW);
Demand = restore(Demand);
Supply = restore(Supply);

if CPF.show && ishandle(Fig.main)
  set(Fig.main,'Pointer','arrow');
  Settings.xlabel = ['Loading Parameter ',char(92),'lambda (p.u.)'];
  Settings.tf = 1.2*lambda_crit;
end

fm_status('cpf','close')

Settings.pv2pq = PV2PQ;
CPF.lambda = lambda_crit;
CPF.kg = kg;

fm_snap('viewsnap',0)

SNB.init = 0;
LIB.init = 0;
CPF.init = 1;
OPF.init = 0;

% --------------------------------
function s = signperm(P)
% --------------------------------

[i,j,p] = find(sparse(P));
idx = find(i ~= j);
q = P(idx,idx);
s = det(q);