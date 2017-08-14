function fm_snb
% FM_SNB compute Saddle-node Bifurcation
%        by means of a Direct Method
%
% FM_SNB
%
%System Equations:
%       g(y,kg,lambda) = 0   ->  operating point
%       dg/dy'*ro = 0        ->  transversality condition
%       |ro| - 1 = 0         ->  non-trivial condition
%
%       where:  g = load flow equations
%               y = [theta; V]
%               ro = right eigenvector
%               lambda = loading parameter
%
% Options:
%          SNB.slack:  1  ->  distribuited slack bus
%                      0  ->  single slack bus
%
% Output:  SNB.lambda: saddle node value of lambda
%          SNB.dldp:   sensitivity factors
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    11-Feb-2003
%Version:   1.0.2
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Settings
fm_var

if ~autorun('SNB Direct Method',0), return, end

% check for continuation power flow solution
% lambda the maximum lambda obtained with the CPF analysis
% or 1e-3 if no CPF analysis has been performed.
if ~CPF.init && ~clpsat.init
  Settings.ok = 0;
  uiwait(fm_choice(['It is strongly recommended running a CPF to get ' ...
      'a solution close to the SNB point. Run CPF?'],1))
  if Settings.ok
    cpf_old = CPF;
    CPF.vlim = 0;
    CPF.ilim = 0;
    CPF.qlim = 0;
    CPF.type = 2;
    CPF.linit = 0;
    CPF.show = 0;
    CPF.nump = 200;
    CPF.step = 0.25;
    fm_cpf('snb');
    lambda = CPF.lambda;
    kg = CPF.kg;
    CPF = cpf_old;
  else
    lambda = 1;
    kg = 1e-3;
  end
else
  lambda = CPF.lambda;
  kg = CPF.kg;
end

distr = SNB.slack;

% check for loaded components
ncload = getnum(Mn) + getnum(Pl) + getnum(Lines);
if ncload || DAE.n
  fm_disp('only PV, PQ and SW buses are allowed for SNB computations.')
  return
end

fm_disp
if distr
  fm_disp('Direct Method for SNB Computation - Distribuited Slack Bus')
else
  fm_disp('Direct Method for SNB Computation - Single Slack Bus')
end
fm_disp('                                  - Right Eigenvector')
fm_disp
fm_disp(['Data file "',Path.data,File.data,'"'])
fm_disp

noDem = 0;
noSup = 0;
pv2pq = Settings.pv2pq;
Settings.pv2pq = 0;
forcepq = Settings.forcepq;
Settings.forcepq = 1;

% if no Demand.con is used, the load power direction
% is assumed to be the one defined by the PQ loads
if Demand.n
  no_dpq = findzero(Demand);
  if ~isempty(no_dpq),
    fm_disp
    for i = 1:length(no_dpq)
      fm_disp(['No power direction found in "Demand.con" for Bus ', ...
               Bus.names{Demand.bus(no_dpq(i))}])
    end
    fm_disp('Continuation power flow routine may have convergence problems.',2)
    fm_disp
  end
else
  noDem = 1;
end

% if no Supply.con is used, the generator power direction
% is assumed to be equal to the PV one
if Supply.n
  no_sp = findzero(Supply);
  if ~isempty(no_sp),
    fm_disp
    if length(no_sp) == Supply.n
      fm_disp(['No power directions found in "Supply.con" for all buses.'])
      fm_disp('Remove "Supply" components or set power directions.')
      fm_disp('Continuation power flow interrupted',2)
      if CPF.show, set(Fig.main,'Pointer','arrow'); end
      return
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
end

% vector and matrix initialization
DAE.Gl = sparse(DAE.m,1);
DAE.Gk = sparse(DAE.m,1);
Nrow = sparse(1,DAE.m+1);
Ncol = sparse(DAE.m,1);
Nmat = sparse(DAE.m+1,DAE.m+1);
Kjac = sparse(1,DAE.m+1);
Kjac(1,SW.refbus) = 1;

if ~distr, SW = setgamma(SW); end

if noDem
  Glcall(PQ);
else
  Glcall(Demand);
end

Glcall(Supply);
if distr, Gkcall(Supply); end

if noSup
  Glcall(PV);
  if distr, Gkcall(PV); end
  Glcall(SW);
end
Gkcall(SW);

if SW.n, DAE.Gl(getbus(SW,'v')) = 0; end
if PV.n, DAE.Gl(getbus(PV,'v')) = 0; end

[Vect,D] = eig(full(DAE.Gy));
diagD = diag(D);
idx = find(diagD == 1);
if ~isempty(idx)
  diagD(idx) = 1e6;
end
[val,idx] = min(abs(diagD));
Vect = inv(Vect.');
M = real(Vect(:,idx))+1e-4;
Z = 0;

iter_max = Settings.lfmit;
iteration = 0;
tol = Settings.lftol;
g1 = ones(DAE.m,1);
if DAE.n == 0, dynordold = 0; DAE.n = 1; end

%  Direct Method
tic

fm_status('snb','init',iter_max,{'r'},{'-'},{'g'})

y_old = DAE.y;
l_old = lambda;
k_old = kg;
m_old = M;
z_old = Z;

Settings.error = tol+1;
err_max_old = Settings.error + 1;
robust = 1;

while Settings.error > tol
  if (iteration > iter_max), break, end
  if ishandle(Fig.main)
    if ~get(Fig.main,'UserData'), break, end
  end

  %DAE.Gl = sparse(DAE.m,1);
  %DAE.Gk = sparse(DAE.m,1);

  % call components functions and models
  Line = gcall(Line);
  gcall(Shunt)
  Gycall(Line)
  Gycall(Shunt)
  if noDem
    glambda(PQ,lambda);
    %Glcall(PQ);
  else
    gcall(PQ);
    glambda(Demand,lambda);
    %Glcall(Demand);
  end

  glambda(Supply,lambda,distr*kg);
  %Glcall(Supply);
  %if distr, Gkcall(Supply); end

  if noSup
    glambda(PV,lambda,distr*kg)
    glambda(SW,lambda,kg)
    greactive(PV)
    %if distr, Gkcall(PV), end
    %Glcall(PV)
    Gyreactive(PV)
    %Glcall(SW)
  else
    gcall(PV);
    Gycall(PV);
    glambda(SW,1,kg)
  end
  %Gkcall(SW)
  greactive(SW)
  Gyreactive(SW)

  % non-trivial condition ||w|| = 1
  norm_eq = norm([M',Z]);
  Vjac = [M',Z]/norm_eq;
  gy = [DAE.Gy, DAE.Gk; Kjac]'*[M;Z];

  % complete Jacobian matrix
  AC = [[hessian(Line,M),Ncol;Nrow],[DAE.Gy,DAE.Gk; Kjac]',[Ncol;0]; ...
        [DAE.Gy,DAE.Gk;Kjac],Nmat,[DAE.Gl;0];Nrow,Vjac,0];

  inc = -robust*(AC\[gy; DAE.g; DAE.y(SW.refbus); norm_eq-1]);
  Settings.error = max(abs(inc));

  if Settings.error > 2*err_max_old && iteration

    DAE.y  = y_old;
    lambda = l_old;
    kg = k_old;
    M  = m_old;
    Z  = z_old;

    robust = 0.5*robust;
    if robust < tol, iteration = iter_max+1; break, end

  else

    y_old = DAE.y;
    l_old = lambda;
    k_old = kg;
    m_old = M;
    z_old = Z;

    DAE.y = DAE.y + inc(1:DAE.m);         idx = DAE.m;
    kg = kg + inc(idx+1);                 idx = idx + 1;
    M = M + inc(idx+1:idx+DAE.m);         idx = idx + DAE.m;
    Z = Z + inc(idx+1);                   idx = idx + 1;
    lambda = lambda + inc(idx+1);

    err_max_old = Settings.error;
    iteration = iteration + 1;
    if Settings.show
      fm_disp(['iteration = ', int2str(iteration), ...
               ';   lambda = ',num2str(lambda), ...
               '   kg = ',num2str(kg), ...
               '   err = ',num2str(Settings.error)])
    end
    fm_status('snb','update',[iteration, Settings.error],iteration)
  end
end

% ===========================================================================
%                                  d lambda |
% sensistivity coefficients        -------- |
%                                     d p   |c
% ===========================================================================

W = [M; Z];
d1 = DAE.m+1;
d2 = Supply.n;
d3 = Demand.n;
Sbus = double(Supply.bus);
Dbus = Demand.bus;
if noDem
  d3 = PQ.n;
  Dbus = double(PQ.bus);
end
if noSup
  d2 = getnum(SW) + getnum(PV);
  Sbus = double([getbus(PV);getbus(SW)]);
end
Dpfc = sparse(d1,d2+d3);
Dpfc = Dpfc + sparse(Sbus,[1:d2],-(lambda+kg),d1,d2+d3);
Dpfc = Dpfc + sparse(Dbus,d2+[1:d3],lambda,d1,d2+d3);

dl_dp = full(-W'*Dpfc/(W'*[DAE.Gl;0]))';

% Update Pg, Qg, Pl and Ql
% ===========================================================================

DAE.g = zeros(DAE.m,1);
fm_call('load');
glambda(Demand,lambda)
Bus.Pl = DAE.g(Bus.a);
Bus.Ql = DAE.g(Bus.v);
fm_call('gen');
Bus.Pg = DAE.g(Bus.a);
Bus.Qg = DAE.g(Bus.v);

% Display results
% ===========================================================================
serv_test{1,1} = ['lambda = ',fvar(lambda,8)];
serv_test{2,1} = ['kg = ',fvar(kg,8)];
serv_test{3,1} = '  ';

if d2
  serv_test = [serv_test;fm_strjoin('d lambda / d Ps_',Bus.names(Sbus), ...
                                '=',num2str(dl_dp(1:d2)))];
end
serv_test{end+1,1} = ' ';
if d3
  serv_test = [serv_test;fm_strjoin('d lambda / d Pd_',Bus.names(Dbus), ...
                                '=',num2str(dl_dp(d2+[1:d3])))];
end
fm_disp
DAE.n = dynordold;
Settings.iter = iteration;

Settings.lftime = toc;
if robust < tol
  fm_disp('Increment step below threshold. Bad initial point. SNB routine stopped.',2)
elseif iteration >= iter_max
  fm_disp(['Direct Method for SNB did not converge.'],2)
else
  fm_disp(['Direct Method for SNB completed in ',num2str(toc),' s'])
  if Settings.showlf == 1, fm_stat(serv_test), end
end

SNB.lambda = lambda;
SNB.dldp = dl_dp;

if Settings.matlab && Settings.hostver >= 7.14,
  SNB.bus = char([cell(fm_strjoin('s_',num2str(Supply.bus))); ...
                  cell(fm_strjoin('d_',num2str(Demand.bus)))]);
else
  SNB.bus = strvcat(fm_strjoin('s_',num2str(Supply.bus)), ...
                    fm_strjoin('d_',num2str(Demand.bus)));
end

% restore original data
% ===========================================================================
fm_status('snb','close')

Settings.forcepq = forcepq;
Settings.pv2pq = pv2pq;

PQ = pqreset(PQ,'all');
SW = restore(SW);

SNB.init = 1;
LIB.init = 0;
CPF.init = 0;
OPF.init = 0;