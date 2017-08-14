function fm_opfsdr
%FM_OPFSDR solve the OPF-based  electricity market problem by means of
%          an Interior Point Method with a Merhotra Predictor-Corrector
%          or Newton direction technique.
%          Voltage stability limits are included (see equations below).
%
%System equations:
%
%Min:  (1-w)*(Cs'*Ps - Cd'Pd + Cr*Pr) - w*lc
%
%s.t.: f(theta,V,Qg,Ps,Pd) = 0           (PF eq.)
%      f(thetac,Vc,Qgc,Ps,Pd,kg,lc) = 0  (PF eq. crit.)
%      lc_max >= lc >= lc_min            (min. stab. margin)
%      Ps_min <= Ps <= Ps_max            (supply bid blocks)
%      Pd_min <= Pd <= Pd_max            (demand bid blocks)
%  *   Ps + Pr <= Ps_max                 (reserve blocks)
%  *   Pr_min <= Pr <= Pr_max
%  *   sum(Pr) <= sum(Pd)
%      |Iij(theta,V)|   <= I_max         (thermal or power limits)
%      |Iij(thetac,Vc)| <= I_max
%      |Iji(theta,V)|   <= I_max
%      |Iji(thetac,Vc)| <= I_max
%      Qg_min  <= Qg  <= Qg_max          (gen. Q limits)
%      Qgc_min <= Qgc <= Qgc_max
%      V_min  <= V  <= V_max             (bus voltage limits)
%      Vc_min <= Vc <= Vc_max
%
%(* optional constraints)
%
%see also FM_OPFM FM_PARETO FM_ATC and the OPF structure for settings.
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

fm_var

if ~autorun('Optimal Power Flow',0)
  return
end

if DAE.n
  fm_disp('OPF routine does not support dynamic components',2)
  return
end

if ~Supply.n,
  fm_disp('Supply data have to be specified before in order to run OPF routines',2)
  return
end

lcmin = OPF.lmin;
lcmax = OPF.lmax;
w = OPF.w;
if w > 1 || w < 0
  fm_disp('The weigthing factor range is [0,1]')
  return
end

if OPF.show
  fm_disp
  fm_disp('----------------------------------------------------------------')
  fm_disp('Interior Point Method for OPF Computation')
  fm_disp('Spot Price of Security (including loading parameter)')
  if w > 0 && w < 1,
    fm_disp('Multi-Objective Function')
  elseif w == 0,
    fm_disp('Social Benefit Objective Function')
  elseif w == 1,
    fm_disp('Maximization of the Distance to Collapse')
  end
  fm_disp(['Minimum Loading Parameter = ',num2str(lcmin)])
  fm_disp(['Weighting Factor = ',num2str(w)])
  fm_disp(['Data file "',Path.data,File.data,'"'])
  fm_disp('----------------------------------------------------------------')
  fm_disp
end

tic;
if w == 0, w = 1e-5; end
if OPF.flatstart == 1
  DAE.y(Bus.a) = getzeros(Bus);
  DAE.y(Bus.v) = getones(Bus);
  Bus.Qg = 1e-3*ones(Bus.n,1);
else
  length(Snapshot.y);
  DAE.y = Snapshot(1).y;
  Bus.Qg = Snapshot(1).Qg;
end
if ~Demand.n,
  if OPF.basepg && ~clpsat.init
    Settings.ok = 0;
    uiwait(fm_choice(['It is strongly recommended to exclude ' ...
                      'base case powers. Do you want to do so?']))
    OPF.basepg = ~Settings.ok;
  end
  noDem = 1;
  Demand = add(Demand,'dummy');
else
  noDem = 0;
end

Bus.Pg = Snapshot(1).Pg;
forcepq = Settings.forcepq;
Settings.forcepq = 1;
if ~OPF.basepl
  Bus.Pl(:) = 0;
  Bus.Ql(:) = 0;
  PQ = pqzero(PQ,'all');
end
if ~OPF.basepg
  Bus.Pg(:) = 0;
  Bus.Qg(:) = 0;
  PV = pvzero(PV,'all');
  SW = swzero(SW,'all');
end

% ===========================================================================
% Definition of vectors: parameters, variables and Jacobian matrices
% ===========================================================================

% Parameters
% ===========================================================================

% Supply parameters
[Csa,Csb,Csc,Dsa,Dsb,Dsc] = costs(Supply);
[Psmax,Psmin] = plim(Supply);
KTBS = tiebreaks(Supply);
ksu = getgamma(Supply);

% Demand parameters
[Cda,Cdb,Cdc,Dda,Ddb,Ddc] = costs(Demand);
[Pdmax,Pdmin] = plim(Demand);
KTBD = tiebreaks(Demand);
qonp = tanphi(Demand);

% Reserve parameters
Cr = costs(Rsrv);
[Prmax,Prmin] = plim(Rsrv);
DPr = [];
Pr = [];

busG = double([SW.bus; PV.bus]);
busS = setdiff(busG,Supply.bus);
n_gen = Supply.n+length(busS);
busG = [Supply.bus;busS];
[supR,idxR,dummy] = intersect(Supply.bus,Rsrv.bus);

nS = 1:Supply.n;
nD = 1:Demand.n;
nG = 1:n_gen;
nB = Bus.a';
nV = Bus.v';
nY = 1:DAE.m;
nL = 1:Line.n;
nR = 1:Rsrv.n;

if OPF.enreac
  [Qgmax,Qgmin] = fm_qlim('gen');
else
  Qgmin = -99*Settings.mva*ones(n_gen,1);
  Qgmax =  99*Settings.mva*ones(n_gen,1);
end

if OPF.envolt
  [Vmax,Vmin] = fm_vlim(OPF.vmax,OPF.vmin);
else
  Vmin = OPF.vmin*getones(Bus);
  Vmax = OPF.vmax*getones(Bus);
end
Vcmin = Vmin;
Vcmax = Vmax;

if OPF.enflow
  Iijmax = getflowmax(Line,OPF.flow).^2;
else
  Iijmax = 999*999*ones(Line.n,1);
end
Iijcmax = Iijmax;
if OPF.line, status = Line.u(OPF.line); end

iteration = 0;
iter_max = Settings.lfmit;
Settings.error = Settings.lftol+1;

% Graphical Settings
% ===========================================================================

fm_status('opf','init',iter_max,{Theme.color08,'b','g','y'}, ...
          {'-','-','-','-'},{Theme.color11, Theme.color11, ...
                    Theme.color11,Theme.color11})

% Variables
% ===========================================================================

% Lagrangian multipliers [mu]
mu_t = getzeros(Bus);

% numbering
n1 = Bus.n;
n2 = 2*n1;
n3 = 3*n1;
n4 = 4*n1;
n_a = n_gen + Demand.n + Supply.n;
n_b = 2*n_a+2*n_gen+n4+2;
n_c = n_b+4*Line.n;
n_d = Supply.n+Demand.n+2*n_gen+n4+2;
n_s = 2*Supply.n+2*Demand.n+4*n_gen+n4+2+4*Line.n+2*Rsrv.n;
if Rsrv.n, n_s = n_s + 1; end
n_y = Supply.n+Demand.n+2*n_gen+n4+2+Rsrv.n;

% y variables
yc = DAE.y;
lc = lcmin + 0.001*(lcmax-lcmin);
kg = 0.0001;

ro = zeros(n4,1);     % Dual Variables [ro]
sigma = OPF.sigma;         % Centering Parameter [sigma]
ms = sigma/n_s;            % Barrier Parameter [ms]
gamma = OPF.gamma;         % Safety Factor [gamma]
epsilon_mu = OPF.eps_mu;   % Convergence Tolerances
epsilon_1  = OPF.eps1;
epsilon_2  = OPF.eps2;
G_obj = 1;                 % Objective Function

% Jacobian Matrices
% ===========================================================================

Jz1 = sparse(n2,n2+n_gen+2+Rsrv.n);
Jz2 = sparse(n2,n2+n_gen);
g_Qg = sparse(n1+busG,nG,-ones(n_gen,1),n2,n_gen);
g_Ps = sparse(Supply.bus,nS,-ones(Supply.n,1),n2,Supply.n);
g_Pd = sparse(Demand.bus,nD,ones(Demand.n,1),n2,Demand.n);
g_Pd = g_Pd + sparse(Demand.vbus,nD,qonp,n2,Demand.n);
g_Qgc = sparse(n1+busG,nG,-ones(n_gen,1),n2,n_gen);
g_Psc = sparse(n2,Supply.n);
g_Pdc = sparse(n2,Demand.n);
DAE.Gl = zeros(n2,1);
DAE.Gk = zeros(n2,1);
dF_dy = sparse(n_y,1);
dG_dy = sparse(n2+n_gen+1:n2+n_a,1,(1-w)*[Csb;-Cdb],n_y,1);
dH_dy = sparse(n_y,1);
gy = sparse(n_y,1);
Jh = sparse(n_s,n_y);

Jh = Jh + sparse(nS,n2+n_gen+nS,-1,n_s,n_y);
Jh = Jh + sparse(Supply.n+nS,n2+n_gen+nS,1,n_s,n_y);
Jh = Jh + sparse(2*Supply.n+nD,n2+n_gen+Supply.n+nD,-1,n_s,n_y);
Jh = Jh + sparse(2*Supply.n+Demand.n+nD,n2+n_gen+Supply.n+nD,1,n_s,n_y);
Jh = Jh + sparse(2*Supply.n+2*Demand.n+nG,n2+nG,-1,n_s,n_y);
Jh = Jh + sparse(2*Supply.n+2*Demand.n+n_gen+nG,n2+nG,1,n_s,n_y);
Jh = Jh + sparse(2*n_a+nB,nV,-1,n_s,n_y);
Jh = Jh + sparse(2*n_a+nV,nV,1,n_s,n_y);
Jh = Jh + sparse(2*n_a+n2+nG,1+n4+n_a+nG,-1,n_s,n_y);
Jh = Jh + sparse(2*n_a+n2+n_gen+nG,1+n4+n_a+nG,1,n_s,n_y);
Jh = Jh + sparse(2*n_a+2*n_gen+n2+nB,n3+n_a+nB,-1,n_s,n_y);
Jh = Jh + sparse(2*n_a+2*n_gen+n3+nB,n3+n_a+nB,1,n_s,n_y);
Jh(2*n_a+2*n_gen+n4+1, n_d) = -1;
Jh(2*n_a+2*n_gen+n4+2, n_d) =  1;

if Rsrv.n, % Power Reserve
  g_Pr  = sparse(n2,Rsrv.n);
  dG_dy(n_d+nR) = (1-w)*Cr;
  Jh = Jh + sparse(n_c+nR,n_d+nR,-1,n_s,n_y);
  Jh = Jh + sparse(n_c+Rsrv.n+nR,n_d+nR,1,n_s,n_y);
  Jh = Jh + sparse(n_c+2*Rsrv.n+1,n_d+nR,1,n_s,n_y);
  Jh = Jh + sparse(n_c+2*Rsrv.n+1,n2+n_gen+Supply.n+nD,-1,n_s,n_y);
end

Jg = sparse(n4,n_y);

% Hessian Matrices but Gy
% ===========================================================================

%I_smu = speye(n_s);
%Z1 = sparse(n_s,n_y);
%Z2 = sparse(n_s,n_s);
Z3 = sparse(n4,n4);
%Z4 = sparse(n4,n_s);
Hcolk = sparse(n2,1);
Hrowk = sparse(1,n2+1);
H31 = sparse(n2,n_gen+n_a+n2+2+Rsrv.n);
H41 = sparse(n2+1,n2+n_a);
H42 = sparse(n2+1,n_gen+1+Rsrv.n);
H5  = sparse(n_gen+1+Rsrv.n,n_y);

% ===========================================================================
% Choosing the Initial Point
% ===========================================================================

% Primal Variables
% ===========================================================================

Ps = Psmin + 0.5*(Psmax-Psmin);
if Rsrv.n
  Pr = Prmin + 0.1*(Prmax-Prmin);
  Pdbas = sum(Pr)/Supply.n;
else
  Pdbas = 0;
end
Pd = Pdmin + 0.5*(Pdmax-Pdmin) + Pdbas;
Qg = 0.5*(Qgmax+Qgmin);
Qgc = Qg;

[Iij,Iji] = flows(Line, OPF.flow);
Iijc = Iij;
Ijic = Iji;
a = [];
b = [];

% check flow limits
a = find(Iij > sqrt(Iijmax));
b = find(Iji > sqrt(Iijmax));
if ~isempty(a) || ~isempty(b)
  fm_disp('Actual line flows are greater than imposed limits',1)
  fm_disp(['Check limits of the following lines:'],1)
  fm_disp('          from     to',1)
  for i = 1:length(a)
    fm_disp(['    Line ',fvar(Line.fr(a(i)),5), ...
             ' -> ', fvar(Line.to(a(i)),5),': ',fvar(Iij(a(i)),7), ...
             ' > ', fvar(sqrt(Iijmax(a(i))),7)],1)
  end
  for i = 1:length(b)
    fm_disp(['    Line ',fvar(Line.to(b(i)),5), ...
             ' -> ', fvar(Line.fr(b(i)),5),': ',fvar(Iji(b(i)),7), ...
             ' > ', fvar(sqrt(Iijmax(b(i))),7)],1)
  end
end

if ~isempty(a)
  a1 = Line.to(a);
  a2 = Line.fr(a);
  v1 = Line.vto(a);
  v2 = Line.vfr(a);
  DAE.y(v1) = DAE.y(v2);
  DAE.y(a1) = DAE.y(a2);
  yc(v1) = DAE.y(v2);
  yc(a1) = DAE.y(a2);
end
if ~isempty(b)
  b1 = Line.to(b);
  b2 = Line.fr(b);
  v1 = Line.vto(b);
  v2 = Line.vfr(b);
  DAE.y(v1) = DAE.y(v2);
  DAE.y(b1) = DAE.y(b2);
  yc(v1) = DAE.y(v2);
  yc(b1) = DAE.y(b2);
end

% check voltage limits
Vbus = DAE.y(Bus.v);
a = find(Vbus > Vmax);
b = find(Vbus < Vmin);
if ~isempty(a),
  fm_disp(['Max Voltage limit not respected at buses: ',num2str(a')],1)
  for i = 1:length(a)
    fm_disp(['     Bus #',fvar(Bus.con(a(i),1),4),' -> ',fvar(Vbus(a(i)),8), ...
             ' > ', fvar(Vmax(a(i)),8)],1)
  end
end
if ~isempty(b),
  fm_disp(['Min Voltage limit not respected at buses: ',num2str(b')],1)
  for i = 1:length(b)
    fm_disp(['     Bus #',fvar(Bus.con(b(i),1),4),' -> ',fvar(Vbus(b(i)),8), ...
             ' < ', fvar(Vmin(b(i)),8)],1)
  end
end
if ~isempty(a) || ~isempty(b)
  Vbus = max(Vbus,Vmin+1e-3);
  Vbus = min(Vbus,Vmax-1e-3);
  DAE.y(Bus.v) = Vbus;
  yc(Bus.v) = Vbus;
end

h_delta_Ps   = Psmax - Psmin;
h_delta_Pd   = Pdmax - Pdmin;
h_delta_Qg   = Qgmax - Qgmin;
h_delta_V    = Vmax  - Vmin;
h_delta_Vc   = Vcmax - Vcmin;
h_delta_lc   = lcmax - lcmin;
h_delta_Iij  = Iijmax;
h_delta_Iji  = Iijmax;
h_delta_Iijc = Iijcmax;
h_delta_Ijic = Iijcmax;

gamma_h = 0.25;

a_Ps  = min(max(gamma_h*h_delta_Ps,Ps-Psmin),(1-gamma_h)*h_delta_Ps);
a_Pd  = min(max(gamma_h*h_delta_Pd,Pd-Pdmin),(1-gamma_h)*h_delta_Pd);
a_Qg  = min(max(gamma_h*h_delta_Qg,Qg-Qgmin),(1-gamma_h)*h_delta_Qg);
a_V   = min(max(gamma_h*h_delta_V,Vbus-Vmin),(1-gamma_h)*h_delta_V);
a_Vc  = min(max(gamma_h*h_delta_Vc,Vbus-Vcmin),(1-gamma_h)*h_delta_Vc);
a_lc  = min(max(gamma_h*h_delta_lc,lc-lcmin),(1-gamma_h)*h_delta_lc);
a_Iij = min(max(gamma_h*h_delta_Iij,Iij),(1-gamma_h)*h_delta_Iij);
a_Iji = min(max(gamma_h*h_delta_Iji,Iji),(1-gamma_h)*h_delta_Iji);
a_Iijc= min(max(gamma_h*h_delta_Iijc,Iij),(1-gamma_h)*h_delta_Iijc);
a_Ijic= min(max(gamma_h*h_delta_Ijic,Iji),(1-gamma_h)*h_delta_Ijic);

s = [a_Ps; h_delta_Ps - a_Ps; a_Pd; h_delta_Pd - a_Pd; ...
     a_Qg; h_delta_Qg - a_Qg; a_V; h_delta_V  - a_V; ...
     a_Qg; h_delta_Qg - a_Qg; a_Vc; h_delta_Vc - a_Vc; ...
     a_lc; h_delta_lc - a_lc; h_delta_Iij  - a_Iij; ...
     h_delta_Iijc - a_Iijc; h_delta_Iji  - a_Iji; h_delta_Ijic - a_Ijic];

idx = find(s == 0);
if ~isempty(idx),
  s(idx) = 1e-6;
  fm_disp('Problems in initializing slack variables...')
end

if Rsrv.n
  sumPrd = sum(Pr)-sum(Pd);
  h_delta_Pr   = Prmax - Prmin;
  a_Pr  = min(max(gamma_h*h_delta_Pr,Pr),(1-gamma_h)*h_delta_Pr);
  s = [s; a_Pr; h_delta_Pr - a_Pr; -sumPrd];
end

% Dual Variables
% =====================================================

mu = ms./s;
if w < 1, ro(Bus.a) = -mean([Csb; Cdb]); end

if Settings.matlab, warning('off'); end

% =======================================================================
% PRIMAL DUAL INTERIOR-POINT METHOD
% =======================================================================

while 1

  if ishandle(Fig.main)
    if ~get(Fig.main,'UserData'), break, end
  end

  % =======================================================================
  % KKT optimality necessary condition: [DyLms] = 0
  % =======================================================================

  % Saving Objective Function (k-1)
  % =====================================================

  G_obj_k_1 = G_obj;

  mu_Psmin  = mu(nS);         idx = Supply.n;
  mu_Psmax  = mu(idx+nS);     idx = idx + Supply.n;
  mu_Pdmin  = mu(idx+nD);     idx = idx + Demand.n;
  mu_Pdmax  = mu(idx+nD);     idx = idx + Demand.n;
  mu_Qgmin  = mu(idx+nG);     idx = idx + n_gen;
  mu_Qgmax  = mu(idx+nG);     idx = idx + n_gen;
  mu_Vmin   = mu(idx+nB);     idx = idx + n1;
  mu_Vmax   = mu(idx+nB);     idx = idx + n1;
  mu_Qgcmin = mu(idx+nG);     idx = idx + n_gen;
  mu_Qgcmax = mu(idx+nG);     idx = idx + n_gen;
  mu_Vcmin  = mu(idx+nB);     idx = idx + n1;
  mu_Vcmax  = mu(idx+nB);     idx = idx + n1;
  mu_lcmin  = mu(idx+1);      idx = idx + 1;
  mu_lcmax  = mu(idx+1);      idx = idx + 1;
  mu_Iijmax = mu(idx+nL);     idx = idx + Line.n;
  mu_Iijcmax= mu(idx+nL);     idx = idx + Line.n;
  mu_Ijimax = mu(idx+nL);     idx = idx + Line.n;
  mu_Ijicmax= mu(idx+nL);     idx = idx + Line.n;
  if Rsrv.n
    mu_Prmin  = mu(idx+nR);   idx = idx + Rsrv.n;
    mu_Prmax  = mu(idx+nR);   idx = idx + Rsrv.n;
    mu_sumPrd = mu(idx+1);
  end

  % Computations for the System:  f(thetac,Vc,Qgc,Ps,Pd,lc) = 0
  % =====================================================

  y_snap = DAE.y;
  DAE.y  = yc;
  DAE.Gl = zeros(n2,1);
  DAE.Gk = zeros(n2,1);

  if OPF.line, Line = setstatus(Line,OPF.line,0); end

  Line = gcall(Line);
  gcall(Shunt)
  glambda(SW,1+lc,kg);
  glambda(PV,1+lc,kg);
  glambda(PQ,1+lc);

  Glcall(SW);
  Gkcall(SW);
  Glcall(PV);
  Gkcall(PV);
  Glcall(PQ);

  % generator reactive powers
  DAE.g = DAE.g - sparse(busG+n1,1,Qgc,DAE.m,1);

  % Demand & Supply
  DAE.g = DAE.g + sparse(Demand.bus,1,(1+lc)*Pd,DAE.m,1) ...
          + sparse(Demand.vbus,1,(1+lc)*Pd.*qonp,DAE.m,1);
  DAE.Gl = DAE.Gl + sparse(Demand.bus,1,Pd,DAE.m,1) ...
           + sparse(Demand.vbus,1,Pd.*qonp,DAE.m,1);
  g_Pdc = sparse(Demand.bus,nD,1+lc,DAE.m,Demand.n) ...
          + sparse(Demand.vbus,nD,(1+lc)*qonp,DAE.m,Demand.n);
  DAE.g = DAE.g - sparse(Supply.bus,1,(1+lc+kg*ksu).*Ps,DAE.m,1);
  g_Psc = sparse(Supply.bus,nS,-(1+lc+kg*ksu),DAE.m,Supply.n);
  DAE.Gl = DAE.Gl - sparse(Supply.bus,1,Ps,DAE.m,1);
  DAE.Gk = DAE.Gk - sparse(Supply.bus,1,ksu.*Ps,DAE.m,1);

  %DAE.g(SW.refbus) = 0;
  gc1 = DAE.g;
  gc2p = Line.p;
  gc2q = Line.q;

  Gycall(Line)
  Gycall(Shunt)
  %DAE.Gy(:,SW.refbus) = 0;
  Gyc = DAE.Gy;
  [Iijc,Jijc,Hijc,Ijic,Jjic,Hjic] = fjh2(Line,OPF.flow,mu_Iijcmax,mu_Ijicmax);
  Hess_c = -hessian(Line,ro(n2+1:n4))+Hijc+Hjic-hessian(Shunt,ro(n2+1:n4));

  % Computations for the System:  f(theta,V,Qg,Ps,Pd) = 0
  % =====================================================

  DAE.y = y_snap;

  if OPF.line, Line = setstatus(Line,OPF.line,status); end

  Line = gcall(Line);
  gcall(Shunt)
  gcall(PQ);
  glambda(SW,1,0);
  glambda(PV,1,0);

  % Demand & Supply
  DAE.g = DAE.g + sparse(Demand.bus,1,Pd,DAE.m,1) ...
          + sparse(Demand.vbus,1,Pd.*qonp,DAE.m,1) ...
          - sparse(Supply.bus,1,Ps,DAE.m,1) ...
          - sparse(busG+n1,1,Qg,DAE.m,1);
  %DAE.g(SW.refbus) = 0;

  Gycall(Line)
  Gycall(Shunt)
  %DAE.Gy(:,SW.refbus) = 0;
  %fm_setgy(SW.refbus)
  [Iij,Jij,Hij,Iji,Jji,Hji] = fjh2(Line,OPF.flow,mu_Iijmax,mu_Ijimax);
  Hess = -hessian(Line,ro(1:n2))+Hij+Hji-hessian(Shunt,ro(1:n2));

  % Gradient of [s] variables
  % =====================================================

  gs = s.*mu - ms;

  % Gradient of [mu] variables
  % =====================================================

  V = DAE.y(Bus.v);
  Vc = yc(Bus.v);
  gmu = [Psmin-Ps;Ps-Psmax;Pdmin-Pd;Pd-Pdmax;Qgmin-Qg;Qg-Qgmax; ...
         Vmin-V;V-Vmax;Qgmin-Qgc;Qgc-Qgmax;Vcmin-Vc;Vc-Vcmax; ...
         lcmin-lc;lc-lcmax;Iij-Iijmax;Iijc-Iijcmax;Iji-Iijmax; ...
         Ijic-Iijcmax];
  if Rsrv.n
    gmu(Supply.n+supR) = gmu(Supply.n+supR) + Pr;
    gmu = [gmu; Prmin-Pr;Pr-Prmax;sum(Pr)-sum(Pd)];
  end
  gmu = gmu + s;

  % Gradient of [y] = [theta; V; Qg; Ps; Pd] variables
  % =====================================================

  if Rsrv.n
    Jg = [DAE.Gy,g_Qg,g_Ps,g_Pd,Jz1; ...
          Jz2,g_Psc,g_Pdc,Gyc,DAE.Gk,g_Qgc,DAE.Gl,g_Pr];
  else
    Jg = [DAE.Gy,g_Qg,g_Ps,g_Pd,Jz1; ...
          Jz2,g_Psc,g_Pdc,Gyc,DAE.Gk,g_Qgc,DAE.Gl];
  end
  Jg(:,SW.refbus) = 0;
  Jg(:,SW.refbus+n_a+n2) = 0;

  dF_dy = Jg'*ro;

  dG_dy(n_d) = -w;                      % max loading factor
  dG_dy(n2+n_gen+1:n2+n_gen+Supply.n) = (1-w)*(Csb + 2*Csc.*Ps + 2*KTBS.*Ps);
  dG_dy(n2+n_gen+Supply.n+1:n2+n_a) =  -(1-w)*(Cdb + 2*Cdc.*Pd + 2*KTBD.*Pd ...
                                               + qonp.*(Ddb + 2*qonp.*Ddc.*Pd));
  dG_dy(n2+nS) = (1-w)*(Dsb + 2*Dsc.*Qg(nS));

  dH_dtV = Jij'*mu_Iijmax + Jji'*mu_Ijimax + [mu_t; mu_Vmax - mu_Vmin];
  dH_dtVc = Jijc'*mu_Iijcmax + Jjic'*mu_Ijicmax + [mu_t; mu_Vcmax - mu_Vcmin];
  if Rsrv.n,
    dH_dy = [dH_dtV; mu_Qgmax-mu_Qgmin; mu_Psmax-mu_Psmin; ...
             mu_Pdmax-mu_Pdmin-mu_sumPrd; ...
             dH_dtVc; 0; mu_Qgcmax - mu_Qgcmin; mu_lcmax - mu_lcmin; ...
             mu_Psmax(idxR)+mu_Prmax-mu_Prmin+mu_sumPrd];
  else
    dH_dy = [dH_dtV; mu_Qgmax-mu_Qgmin; mu_Psmax-mu_Psmin; mu_Pdmax-mu_Pdmin; ...
             dH_dtVc; 0; mu_Qgcmax - mu_Qgcmin; mu_lcmax - mu_lcmin];
  end

  gy = dG_dy - dF_dy + dH_dy;

  Jh(n_b+1:n_b+Line.n,1:n2) = Jij;
  Jh(n_b+1+Line.n:n_b+2*Line.n,1+n2+n_a:n4+n_a) = Jijc;
  Jh(n_b+1+2*Line.n:n_b+3*Line.n,1:n2) = Jji;
  Jh(n_b+1+3*Line.n:n_b+4*Line.n,1+n2+n_a:n4+n_a) = Jjic;

  % Hessian Matrix [D2xLms]
  % --------------------------------------------------------------------

  H3  = sparse(n_a,n_y);
  Hx = -ro(n2+Supply.bus);
  Sidx = 1:Supply.n;
  H3(n_gen+Sidx,n_d) = Hx;
  H3(n_gen+Sidx,n4+1+n_a) = Hx.*ksu;
  H5(n_gen+1,n2+n_gen+Sidx) = Hx';
  H41(end,n2+n_gen+Sidx) = Hx'.*ksu';
  Didx = 1:Demand.n;
  Hx = ro(n2+Demand.bus) + qonp.*ro(n3+Demand.bus);
  H3(n_gen+Supply.n+Didx,n_d) = Hx;
  H5(n_gen+1,n2+n_gen+Supply.n+Didx) = Hx';
  H3 = H3 - sparse(n_gen+nS,n2+n_gen+nS,(1-w)*(2*Csc+2*KTBS),n_a,n_y);
  H3 = H3 - sparse(nS,n2+nS,(1-w)*2*Dsc,n_a,n_y);
  H3 = H3 + sparse(n_gen+Supply.n+nD,n_gen+Supply.n+n2+nD, ...
		   (1-w)*(2*Cdc+2*KTBD+2*Ddc.*qonp.*qonp),n_a,n_y);

  D2xLms = [Hess, H31; -H3; -H41, [Hess_c, Hcolk; Hrowk], H42; -H5];

  switch OPF.method
   case 1 % Newton Directions

    % reduced system
    H_m = sparse(1:n_s,1:n_s,mu./s,n_s,n_s);
    H_s = sparse(1:n_s,1:n_s,1./s,n_s,n_s);
    Jh(:,SW.refbus+n2+n_a) = 0;
    Jh(:,SW.refbus) = 0;
    gy = gy+(Jh.')*(H_m*gmu-H_s*gs);
    Jd = [D2xLms+(Jh.')*(H_m*Jh),-Jg.';-Jg,Z3];
    % reference angle for the actual system
    Jd(SW.refbus,:) = 0;
    Jd(:,SW.refbus) = 0;
    Jd(SW.refbus,SW.refbus) = speye(length(SW.refbus));
    gy(SW.refbus) = 0;
    % reference angle for the critical system
    Jd(:,SW.refbus+n2+n_a) = 0;
    Jd(SW.refbus+n2+n_a,:) = 0;
    Jd(SW.refbus+n2+n_a,SW.refbus+n2+n_a) = speye(length(SW.refbus));
    gy(SW.refbus+n2+n_a) = 0;
    % variable increments
    Dx = -Jd\[gy; -DAE.g; -gc1];
    Ds = -(gmu+Jh*Dx([1:n_y]));
    Dm = -H_s*gs-H_m*Ds;

   case 2 % Mehrotra's Predictor-Corrector

    % -------------------
    % Predictor step
    % -------------------
    % reduced system
    H_m  = sparse(1:n_s,1:n_s,mu./s,n_s,n_s);
    Jh(:,SW.refbus+n2+n_a) = 0;
    Jh(:,SW.refbus) = 0;
    gx = gy+(Jh.')*(H_m*gmu-mu);
    Jd = [D2xLms+(Jh.')*(H_m*Jh),-Jg.';-Jg,Z3];
    % reference angle for the actual system
    Jd(SW.refbus,:) = 0;
    Jd(:,SW.refbus) = 0;
    Jd(SW.refbus,SW.refbus) = speye(length(SW.refbus));
    gx(SW.refbus) = 0;
    % reference angle for the critical system
    Jd(:,SW.refbus+n2+n_a) = 0;
    Jd(SW.refbus+n2+n_a,:) = 0;
    Jd(SW.refbus+n2+n_a,SW.refbus+n2+n_a) = speye(length(SW.refbus));
    gx(SW.refbus+n2+n_a) = 0;
    % LU factorization
    [L,U,P] = lu(Jd);
    % variable increments
    Dx = -U\(L\(P*[gx; -DAE.g; -gc1]));
    Ds = -(gmu+Jh*Dx([1:n_y]));
    Dm = -mu-H_m*Ds;
    % centering correction
    a1 = find(Ds < 0);
    a2 = find(Dm < 0);
    if isempty(a1), ratio1 = 1; else, ratio1 = -s(a1)./Ds(a1);   end
    if isempty(a2), ratio2 = 1; else, ratio2 = -mu(a2)./Dm(a2); end
    alpha_P = min(1,gamma*min(ratio1));
    alpha_D = min(1,gamma*min(ratio2));
    c_gap_af = [s + alpha_P*Ds]'*[mu + alpha_D*Dm];
    c_gap = s'*mu;
    ms = min((c_gap_af/c_gap)^2,0.2)*c_gap_af/n_s;
    gs = mu+(Ds.*Dm-ms)./s;

    % -------------------
    % Corrector Step
    % -------------------
    % new increment for variable y
    gx = gy+(Jh.')*(H_m*gmu-gs);
    gx(SW.refbus) = 0;
    gx(SW.refbus+n2+n_a) = 0;
    % variable increments
    Dx = -U\(L\(P*[gx; -DAE.g; -gc1]));
    Ds = -(gmu+Jh*Dx([1:n_y]));
    Dm = -gs-H_m*Ds;
  end

  % =======================================================================
  % Variable Increments
  % =======================================================================

  Dy  = Dx(nY);          idx = DAE.m;        % curr. sys.
  DQg = Dx(idx+nG);      idx = idx + n_gen;
  DPs = Dx(idx+nS);      idx = idx + Supply.n;
  DPd = Dx(idx+nD);      idx = idx + Demand.n;

  Dyc  = Dx(idx+nY);     idx = idx + DAE.m;  % crit. sys.
  Dkg  = Dx(1+idx);      idx = idx + 1;
  DQgc = Dx(idx+nG);     idx = idx + n_gen;
  Dlc  = Dx(1+idx);      idx = idx + 1;
  if Rsrv.n, DPr = Dx(idx+nR); idx = idx + Rsrv.n;    end

  Dro  = Dx(1+idx:end);                       % Lag. mult.

  % =======================================================================
  % Updating the Variables
  % =======================================================================

  % Step Lenght Parameters [alpha_P & alpha_D]
  %________________________________________________________________________

  a1 = find(Ds  < 0);
  a2 = find(Dm < 0);
  if isempty(a1), ratio1 = 1; else, ratio1 = (-s(a1)./Ds(a1));   end
  if isempty(a2), ratio2 = 1; else, ratio2 = (-mu(a2)./Dm(a2)); end
  alpha_P = min(1,gamma*min(ratio1));
  alpha_D = min(1,gamma*min(ratio2));

  % New primal variables
  %________________________________________________________________________

  DAE.y = DAE.y + alpha_P * Dy;
  Ps = Ps + alpha_P * DPs;
  Pd = Pd + alpha_P * DPd;
  Qg = Qg + alpha_P * DQg;
  if Rsrv.n, Pr = Pr + alpha_P * DPr; end

  yc  = yc  + alpha_P * Dyc;
  kg  = kg  + alpha_P * Dkg;
  Qgc = Qgc + alpha_P * DQgc;
  lc  = lc  + alpha_P * Dlc;
  s   = s   + alpha_P * Ds;

  % New dual variables
  %________________________________________________________________________

  ro = ro + alpha_D*Dro;
  mu = mu + alpha_D*Dm;

  % Objective Function
  %________________________________________________________________________

  s(find(s == 0)) = epsilon_mu;
  Fixd_c = sum(Csa) - sum(Cda) + sum(Dsa) - sum(Dda);
  Prop_c = Csb'*Ps  - Cdb'*Pd + Dsb'*Qg(nS) - Ddb'*(qonp.*Pd);
  TieBreaking = (sum(KTBS.*Ps.*Ps) - sum(KTBD.*Pd.*Pd));
  Quad_c = Csc'*(Ps.*Ps) - Cdc'*(Pd.*Pd) - Ddc'*(qonp.*qonp.*Pd.*Pd);
  Quad_q = Dsc'*(Qg(nS).*Qg(nS));
  if Rsrv.n, Reserve = Cr'*Pr; else, Reserve = 0; end
  G_obj = (1-w)*(Fixd_c + Prop_c + Quad_c + Quad_q + TieBreaking + Reserve) - ...
          ms*sum(log(s)) - w*lc;

  % =======================================================================
  % Reducing the Barrier Parameter
  % =======================================================================

  sigma = max(0.99*sigma, 0.1);     % Centering Parameter
  c_gap = s'*mu;                    % Complementarity Gap
  ms = min(abs(sigma*c_gap/n_s),1); % Evaluation of the Barrier Parameter

  % =======================================================================
  % Testing for Convergence
  % =======================================================================

  test1  = ms <= epsilon_mu;
  norma2 = norm(Dx,inf);
  test2  = norma2 <= epsilon_2;
  norma3 = norm([DAE.g; gc1],inf);
  Settings.error = norma3;
  test3  = norma3 <= epsilon_1;
  norma4 = abs(G_obj-G_obj_k_1)/(1+abs(G_obj));
  test4  = norma4 <= epsilon_2;
  if test1 && test2 && test3 && test4, break, end

  % Displaying Convergence Tests
  %________________________________________________________________________

  iteration = iteration + 1;
  if OPF.show
    fm_disp(['Iter. =',fvar(iteration,5),'  mu =', fvar(ms,8), ...
             '  |dy| =', fvar(norma2,8), '  |f(y)| =', ...
             fvar(norma3,8),'  |dG(y)| =' fvar(norma4,8)])
  end
  fm_status('opf','update',[iteration, ms, norma2, norma3, norma4], ...
            iteration)

  if iteration > iter_max, break, end
end

% Some settings ...
%____________________________________________________________________________

if Settings.matlab, warning('on'); end

Demand = pset(Demand,Pd);
Supply = pset(Supply,Ps);
Rsrv = pset(Rsrv,Pr);

Iij  = sqrt(Iij);
Iji  = sqrt(Iji);
Iijc = sqrt(Iijc);
Ijic = sqrt(Ijic);
Iijmax  = sqrt(Iijmax);
Iijcmax = sqrt(Iijcmax);
MVA = Settings.mva;
Pay = ro(Bus.a).*Line.p*MVA;
ISOPay = sum(Pay);

% Nodal Congestion Prices (NCPs)
%____________________________________________________________________________

fm_setgy(SW.refbus)
dH_dtV(SW.refbus,:) = 0;
OPF.NCP = -DAE.Gy'\dH_dtV;

OPF.obj = G_obj;
OPF.ms = ms;
OPF.dy = norma2;
OPF.dF = norma3;
OPF.dG = norma4;
OPF.iter = iteration;
OPF.gpc = gc2p;
OPF.gqc = gc2q;

SNB.init = 0;
LIB.init = 0;
CPF.init = 0;
OPF.init = 2;

% set Pg, Qg, Pl and Ql
Bus.Pl = OPF.basepl*Snapshot(1).Pl + sparse(Demand.bus,1,Pd,n1,1);
Bus.Ql = OPF.basepl*Snapshot(1).Ql + sparse(Demand.bus,1,Pd.*qonp,n1,1);
Bus.Pg = OPF.basepg*Snapshot(1).Pg + sparse(Supply.bus,1,Ps,n1,1);
Bus.Qg = OPF.basepg*Snapshot(1).Qg + sparse(busG,1,Qg,n1,1);

% Display Results
% --------------------------------------------------

TPQ = totp(PQ);

if (Settings.showlf || OPF.show) && clpsat.showopf

  OPF.report = cell(1,1);
  OPF.report{1,1} = ['Weighting Factor = ',fvar(w,8)];
  OPF.report{2,1} = ['Lambda = ',fvar(lc,8)];
  OPF.report{3,1} = ['Kg = ',fvar(kg,8)];
  OPF.report{4,1} = ['Total Losses = ',fvar(sum(Line.p),8),' [p.u.]'];
  OPF.report{5,1} = ['Bid Losses = ',fvar(sum(Line.p)-Snapshot(1).Ploss,8),' [p.u.]'];

  if ~noDem
    OPF.report{6,1} = ['Total demand = ', ...
                        fvar(sum(Pd),8),' [p.u.]'];
  end
  OPF.report{6+(~noDem),1} = ['TTL = ',fvar(sum(Pd)+TPQ,8),' [p.u.]'];

  fm_disp
  fm_disp('----------------------------------------------------------------')

  Settings.lftime = toc;

  if ishandle(Fig.stat), fm_stat; end

  if iteration > iter_max
    fm_disp('IPM-OPF: Method did not Converge',2)
  elseif ishandle(Fig.main)
    if ~get(Fig.main,'UserData')
      fm_disp('IPM-OPF: Interrupted',2)
    else
      fm_disp(['IPM-OPF completed in ',num2str(toc),' s (omega = ',num2str(w),')'],1)
    end
  else
    fm_disp(['IPM-OPF completed in ',num2str(toc),' s (omega = ',num2str(w),')'],1)
    if Settings.showlf == 1
      fm_stat(OPF.report);
    else
      if Settings.beep
        beep
      end
    end
  end
  fm_status('opf','close')
else
  if iteration > iter_max
    fm_disp('IPM-OPF: Method did not Converge',2)
  elseif ishandle(Fig.main)
    if ~get(Fig.main,'UserData')
      fm_disp(['IPM-OPF: Interrupted'],2)
    else
      fm_disp(['IPM-OPF completed in ',num2str(toc),' s (omega = ',num2str(w),')'],1)
    end
  else
    fm_disp(['IPM-OPF completed in ',num2str(toc),' s (omega = ',num2str(w),')'],1)
  end
end

if iteration > iter_max,
  OPF.conv = 0;
else,
  OPF.conv = 1;
end
if Rsrv.n,
  OPF.guess = [s; mu; DAE.y; Qg; Ps; Pd; ...
               yc; kg; Qgc; lc; Pr; ro];
else
  OPF.guess = [s; mu; DAE.y; Qg; Ps; Pd; ...
               yc; kg; Qgc; lc; ro];
end
OPF.LMP = -ro(1:n1);
OPF.atc = (1+lc)*(sum(Pd)+TPQ)*MVA;
OPF.yc = yc;

if noDem, Demand = restore(Demand); end

Settings.forcepq = forcepq;
if ~OPF.basepl
  PQ = pqreset(PQ,'all');
end
if ~OPF.basepg
  SW = swreset(SW,'all');
  PV = pvreset(PV,'all');
end