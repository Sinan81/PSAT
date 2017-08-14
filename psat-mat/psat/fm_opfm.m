function fm_opfm
%FM_OPFM solves the OPF-based  electricity market problem by means of
%        an Interior Point Method with a Merhotra Predictor-Corrector
%        or Newton direction technique.
%
%System equations:
%
%Min:  Cs'*Ps - Cd'Pd
%
%s.t.: f(theta,V,Qg,Ps,Pd) = 0           (PF eq.)
%      Ps_min <= Ps <= Ps_max            (supply bid blocks)
%      Pd_min <= Pd <= Pd_max            (demand bid blocks)
%   *  Ps + Pr <= Ps_max                 (reserve blocks)
%   *  Pr_min <= Pr <= Pr_max
%   *  sum(Pr) <= sum(Pd)
%      |Iij(theta,V)|   <= I_max         (thermal or power limits)
%      |Iji(theta,V)|   <= I_max
%      Qg_min  <= Qg  <= Qg_max          (gen. Q limits)
%      V_min  <= V  <= V_max             (bus voltage limits)
%
%(* optional constraints)
%
%see also FM_OPFSDR FM_PARETO FM_ATC and the OPF structure for settings.
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    05-Mar-2004
%Version:   1.1.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

fm_var

global Settings

if ~autorun('Optimal Power Flow',0)
  return
end

if DAE.n
  fm_disp('OPF routine does not support dynamic components',2)
  return
end

if ~Supply.n,
  fm_disp('Supply data have to be specified in order to run OPF routines',2)
  return
end

method = OPF.method;
flow = OPF.flow;
forcepq = Settings.forcepq;
Settings.forcepq = 1;
Settings.error = Settings.lftol+1;

if OPF.show
  fm_disp
  fm_disp('----------------------------------------------------------------')
  fm_disp('Interior Point Method for OPF Computation')
  fm_disp('Social Benefit Objective Function')
  fm_disp(['Data file "',Path.data,File.data,'"'])
  fm_disp('----------------------------------------------------------------')
  fm_disp
end

tic;
if OPF.flatstart == 1
  DAE.y(Bus.a) = getzeros(Bus);
  DAE.y(Bus.v) = getones(Bus);
  Bus.Qg = 1e-3*getones(Bus);
else
  length(Snapshot.y);
  DAE.y = Snapshot(1).y;
  Bus.Qg = Snapshot(1).Qg;
end

if ~Demand.n,
  if OPF.basepg && ~clpsat.init
    Settings.ok = 0;
    uiwait(fm_choice(['It is recommended to exclude ' ...
                      'base case powers. Do you want to do so?']))
    OPF.basepg = ~Settings.ok;
    if ishandle(Fig.opf)
      hdl = findobj(Fig.opf,'Tag','CheckboxBaseGen');
      set(hdl,'Value',OPF.basepg)
    end
  end
  noDem = 1;
  Demand = add(Demand,'dummy');
else
  noDem = 0;
end

Bus.Pg = Snapshot(1).Pg;
if ~OPF.basepl
  Bus.Pl(:) = 0;
  Bus.Ql(:) = 0;
  PQ = pqzero(PQ,'all');
end
if ~OPF.basepg
  ploss = Snapshot(1).Ploss;
  Snapshot(1).Ploss = 0;
  Bus.Pg(:) = 0;
  Bus.Qg(:) = 0;
  SW = swzero(SW,'all');
  PV = pvzero(PV,'all');
end

% ===========================================================================
% Definition of vectors: parameters, variables and Jacobian matrices
% ===========================================================================

% Supply parameters
[Csa,Csb,Csc,Dsa,Dsb,Dsc] = costs(Supply);
[Psmax,Psmin] = plim(Supply);
KTBS = tiebreaks(Supply);

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

busG = double([SW.bus;PV.bus]);
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

if OPF.enflow
  Iijmax = getflowmax(Line,flow).^2;
else
  Iijmax = 1e6*ones(Line.n,1);
end

iteration = 0;
iter_max = Settings.lfmit;

% Graphical Settings
%____________________________________________________________________________

fm_status('opf','init',iter_max,{Theme.color08,'b','g','y'}, ...
          {'-','-','-','-'},{Theme.color11, Theme.color11, ...
                    Theme.color11,Theme.color11})

% Variables
%____________________________________________________________________________

% Lagrangian multipliers [mu]
mu_t = getzeros(Bus);

% numbering
n1 = Bus.n;
n2 = 2*n1;
n_a = n_gen + Demand.n + Supply.n;
n_b = 2*n_a+n2;
n_c = n_b+2*Line.n;
n_d = Supply.n+Demand.n+n_gen+n2;
n_s = 2*Supply.n+2*Demand.n+2*n_gen+n2+2*Line.n+2*Rsrv.n;
if Rsrv.n, n_s = n_s + 1; end
n_y = Supply.n+Demand.n+n_gen+n2+Rsrv.n;

ro = zeros(n2,1);   % Dual Variables [ro]
sigma = OPF.sigma;       % Centering Parameter [sigma]
ms = sigma/n_s;          % Barrier Parameter [ms]
gamma = OPF.gamma;       % Safety Factor [gamma]
epsilon_mu = OPF.eps_mu; % Convergence tolerances
epsilon_1 = OPF.eps1;
epsilon_2 = OPF.eps2;
G_obj = 1;               % Objective Function

% Jacobian Matrices
% ===========================================================================

g_Qg = sparse(n1+busG,nG,-1,n2,n_gen);
g_Ps = sparse(Supply.bus,nS,-1,n2,Supply.n);
g_Pd = sparse(Demand.bus,nD, 1,n2,Demand.n);
g_Pd = g_Pd + sparse(Demand.vbus,nD,qonp,n2,Demand.n);
dF_dy = sparse(n_y,1);
dG_dy = sparse([(n2+n_gen+1):(n2+n_a)],1,[Csb;-Cdb],n_y,1);
dH_dy = sparse(n_y,1);
gy = sparse(n_y,1);
Jh = sparse(n_s,n_y);
Jh = Jh - sparse(nS,n2+n_gen+nS,1,n_s,n_y);
Jh = Jh + sparse(Supply.n+nS,n2+n_gen+nS,1,n_s,n_y);
Jh = Jh - sparse(2*Supply.n+nD,n2+n_gen+Supply.n+nD,1,n_s,n_y);
Jh = Jh + sparse(2*Supply.n+Demand.n+nD,n2+n_gen+Supply.n+nD,1,n_s,n_y);
Jh = Jh - sparse(2*Supply.n+2*Demand.n+nG,n2+nG,1,n_s,n_y);
Jh = Jh + sparse(2*Supply.n+2*Demand.n+n_gen+nG,n2+nG,1,n_s,n_y);
Jh = Jh - sparse(2*n_a+nB,nV,1,n_s,n_y);
Jh = Jh + sparse(2*n_a+nV,nV,1,n_s,n_y);

if Rsrv.n, % Power Reserve
  g_Pr  = sparse(n2,Rsrv.n);
  dG_dy(n_d+nR) = Cr;
  Jh = Jh - sparse(n_c+nR,n_d+nR,1,n_s,n_y);
  Jh = Jh + sparse(n_c+Rsrv.n+nR,n_d+nR,1,n_s,n_y);
  Jh = Jh + sparse(n_c+2*Rsrv.n+1,n_d+nR,1,n_s,n_y);
  Jh = Jh - sparse(n_c+2*Rsrv.n+1,n2+n_gen+Supply.n+nD,1,n_s,n_y);
end

Jg = sparse(n2,n_y);

% Hessian Matrices but Gy
% ===========================================================================

Z3 = sparse(n2,n2);
H31 = sparse(n2,n_a+Rsrv.n);

% ===========================================================================
% Choosing the Initial Point
% ===========================================================================


% Primal Variables
% ===========================================================================

Ps = Psmin + 0.1*(Psmax-Psmin);
if Rsrv.n
  Pr = Prmin + 0.1*(Prmax-Prmin);
  Pdbas = sum(Pr)/Supply.n;
else
  Pdbas = 0;
end
Pd = min(Pdmin + 0.1*(Pdmax-Pdmin) + Pdbas,0.9*Pdmax);
Qg = 0.5*(Qgmax+Qgmin);
[Iij,Iji] = flows(Line, OPF.flow);
a = []; b = [];

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
if ~isempty(b)
  DAE.y(Line.vto(b)) = DAE.y(Line.vfr(b));
  DAE.y(Line.to(b))  = DAE.y(Line.fr(b));
end

% check voltage limits
Vbus = DAE.y(Bus.v);
a = find(Vbus > Vmax);
b = find(Vbus < Vmin);
if ~isempty(a),
  fm_disp(['Max Voltage limit not respected at buses: ',num2str(a')],1)
  for i = 1:length(a)
    fm_disp(['     Bus #', fvar(getidx(Bus,a(i)),4), ...
             ' -> ',fvar(Vbus(a(i)),8), ...
             ' > ', fvar(Vmax(a(i)),8)],1)
  end
  fm_disp('Optimization routine interrupted.',1)
  return
end
if ~isempty(b),
  fm_disp(['Min Voltage limit not respected at buses: ',num2str(b')],1)
  for i = 1:length(b)
    fm_disp(['     Bus #', fvar(getidx(Bus,b(i)),4), ...
             ' -> ',fvar(Vbus(b(i)),8), ...
             ' < ', fvar(Vmin(b(i)),8)],1)
  end
  fm_disp('Optimization routine interrupted.',1)
  return
end
if ~isempty(a) || ~isempty(b)
  Vbus = max(Vbus,Vmin+1e-3);
  Vbus = min(Vbus,Vmax-1e-3);
  DAE.y(Bus.v) = Vbus;
end

h_delta_Ps  = Psmax - Psmin;
h_delta_Pd  = Pdmax - Pdmin;
h_delta_Qg  = Qgmax - Qgmin;
h_delta_V   = Vmax  - Vmin;
h_delta_Iij = Iijmax;

gamma_h = 0.25;

a_Ps  = min(max(gamma_h*h_delta_Ps,Ps-Psmin),(1-gamma_h)*h_delta_Ps);
a_Pd  = min(max(gamma_h*h_delta_Pd,Pd-Pdmin),(1-gamma_h)*h_delta_Pd);
a_Qg  = min(max(gamma_h*h_delta_Qg,Qg-Qgmin),(1-gamma_h)*h_delta_Qg);
a_V   = min(max(gamma_h*h_delta_V,Vbus-Vmin),(1-gamma_h)*h_delta_V);
a_Iij = min(max(gamma_h*h_delta_Iij,Iij),(1-gamma_h)*h_delta_Iij);
a_Iji = min(max(gamma_h*h_delta_Iij,Iji),(1-gamma_h)*h_delta_Iij);

s = [a_Ps; h_delta_Ps - a_Ps; a_Pd; h_delta_Pd - a_Pd; ...
     a_Qg; h_delta_Qg - a_Qg; a_V; h_delta_V  - a_V; ...
     h_delta_Iij  - a_Iij; h_delta_Iij  - a_Iji];

idx = find(s == 0);
if ~isempty(idx),
  s(idx) = 1e-6;
end

if Rsrv.n
  %Pr = Prmin + 0.1*(Prmax-Prmin);
  sumPrd = sum(Pr)-sum(Pd);
  h_delta_Pr   = Prmax - Prmin;
  a_Pr  = min(max(gamma_h*h_delta_Pr,Pr),(1-gamma_h)*h_delta_Pr);
  s = [s; a_Pr; h_delta_Pr - a_Pr; -sumPrd];
end

% Dual Variables
%____________________________________________________________________________

mu = ms./s;
ro(Bus.a) = -mean([Csb; Cdb]);
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
  %________________________________________________________________________

  G_obj_k_1 = G_obj;

  mu_Psmin  = mu(nS);         idx = Supply.n;
  mu_Psmax  = mu(idx+nS);     idx = idx + Supply.n;
  mu_Pdmin  = mu(idx+nD);     idx = idx + Demand.n;
  mu_Pdmax  = mu(idx+nD);     idx = idx + Demand.n;
  mu_Qgmin  = mu(idx+nG);     idx = idx + n_gen;
  mu_Qgmax  = mu(idx+nG);     idx = idx + n_gen;
  mu_Vmin   = mu(idx+nB);     idx = idx + n1;
  mu_Vmax   = mu(idx+nB);     idx = idx + n1;
  mu_Iijmax = mu(idx+nL);     idx = idx + Line.n;
  mu_Ijimax = mu(idx+nL);     idx = idx + Line.n;
  if Rsrv.n
    mu_Prmin  = mu(idx+nR);     idx = idx + Rsrv.n;
    mu_Prmax  = mu(idx+nR);     idx = idx + Rsrv.n;
    mu_sumPrd = mu(idx+1);
  end

  % Computations for the System:  f(theta,V,Qg,Ps,Pd) = 0
  %________________________________________________________________________

  Line = gcall(Line);
  gcall(PQ);
  gcall(Shunt)
  glambda(SW,1,0);
  glambda(PV,1,0);

  % Demand & Supply
  DAE.g = DAE.g + sparse(Demand.bus,1,Pd,DAE.m,1) ...
          + sparse(Demand.vbus,1,Pd.*qonp,DAE.m,1);
  DAE.g = DAE.g - sparse(Supply.bus,1,Ps,DAE.m,1) ...
          - sparse(busG+n1,1,Qg,DAE.m,1);

  Gycall(Line)
  Gycall(Shunt)
  [Iij,Jij,Hij,Iji,Jji,Hji] = fjh2(Line,flow,mu_Iijmax,mu_Ijimax);

  % Gradient of [s] variables
  %________________________________________________________________________

  gs = s.*mu - ms;

  % Gradient of [mu] variables
  %________________________________________________________________________

  Vbus = DAE.y(Bus.v);
  gmu = [Psmin-Ps;Ps-Psmax;Pdmin-Pd;Pd-Pdmax;Qgmin-Qg;Qg-Qgmax; ...
         Vmin-Vbus;Vbus-Vmax;Iij-Iijmax;Iji-Iijmax];
  if Rsrv.n,
    gmu(Supply.n+supR) = gmu(Supply.n+supR) + Pr;
    gmu = [gmu; Prmin-Pr;Pr-Prmax;sum(Pr)-sum(Pd)];
  end
  gmu = gmu + s;

  % Gradient of [y] = [theta; V; Qg; Ps; Pd] variables
  %________________________________________________________________________

  Jg = [DAE.Gy, g_Qg, g_Ps, g_Pd];
  if Rsrv.n, Jg = [Jg, g_Pr]; end

  dF_dy = (Jg.')*ro;
  dG_dy(n2+n_gen+nS) = (Csb + 2*Csc.*Ps + 2*KTBS.*Ps);
  dG_dy(n2+n_gen+Supply.n+nD) = -(Cdb+2*Cdc.*Pd+2*KTBD.* ...
                                           Pd+qonp.*(Ddb+2*qonp.*Ddc.*Pd));
  dG_dy(n2+nS) = (Dsb + 2*Dsc.*Qg(nS));
  dH_dtV = (Jij.')*mu_Iijmax + (Jji.')*mu_Ijimax + [mu_t; mu_Vmax-mu_Vmin];
  if Rsrv.n,
    dH_dy = [dH_dtV; mu_Qgmax-mu_Qgmin; mu_Psmax-mu_Psmin; ...
             mu_Pdmax-mu_Pdmin-mu_sumPrd; ...
             mu_Psmax(idxR)+mu_Prmax-mu_Prmin+mu_sumPrd];
  else
    dH_dy = [dH_dtV; mu_Qgmax-mu_Qgmin; mu_Psmax-mu_Psmin; mu_Pdmax-mu_Pdmin];
  end
  gy = dG_dy - dF_dy + dH_dy;

  Jh(n_b+nL,1:n2) = Jij;
  Jh(n_b+Line.n+nL,1:n2) = Jji;

  % Hessian Matrix [D2xLms]
  %________________________________________________________________________

  H3 = sparse(n_a+Rsrv.n,n_y);
  H3 = H3 - sparse(n_gen+nS,n2+n_gen+nS,(2*Csc+2*KTBS),n_a+Rsrv.n,n_y);
  H3 = H3 - sparse(nS,n2+nS,2*Dsc,n_a+Rsrv.n,n_y);
  H3 = H3 + sparse(n_gen+Supply.n+nD,n_gen+Supply.n+n2+nD, ...
                   (2*Cdc+2*KTBD+2*Ddc.*qonp.*qonp),n_a+Rsrv.n,n_y);

  Hess = -hessian(Line,ro(1:n2))+Hij+Hji-hessian(Shunt,ro(1:n2));
  D2xLms = [Hess, H31; -H3];

  % Complete System Matrix [D2yLms]
  %________________________________________________________________________

  %I_smu = speye(n_s);
  %Z1 = sparse(n_s,n_y);
  %Z2 = sparse(n_s,n_s);
  %Z3 = sparse(n2,n2);
  %Z4 = sparse(n2,n_s);
  %H_s  = diag(s);
  %H_mu = diag(mu);
  %D2yLms = [H_mu,    H_s,   Z1,       Z4'; ...
  %          I_smu,   Z2,    Jh,       Z4'; ...
  %          Z1',     Jh',   D2xLms,  -Jg'; ...
  %          Z4,      Z4,   -Jg,       Z3];

  % Compute variable increment
  %________________________________________________________________________

  switch method
   case 1 % Newton Directions

    % reduced system
    H_m = sparse(1:n_s,1:n_s,mu./s,n_s,n_s);
    H_s = sparse(1:n_s,1:n_s,1./s,n_s,n_s);
    Jh(:,SW.refbus) = 0;
    gy = gy+(Jh.')*(H_m*gmu-H_s*gs);
    Jd = [D2xLms+(Jh.')*(H_m*Jh),-Jg.';-Jg,Z3];
    % reference angle for the actual system
    Jd(SW.refbus,:) = 0;
    Jd(:,SW.refbus) = 0;
    %Jd = Jd + sparse(SW.refbus,SW.refbus,1,n_y+DAE.m,n_y+DAE.m);
    Jd(SW.refbus,SW.refbus) = speye(length(SW.refbus));
    gy(SW.refbus) = 0;
    % variable increments
    Dx = -Jd\[gy; -DAE.g];
    Ds = -(gmu+Jh*Dx([1:n_y]));
    Dm = -H_s*gs-H_m*Ds;

   case 2 % Mehrotra's Predictor-Corrector

    % -------------------
    % Predictor step
    % -------------------
    % reduced system
    H_m = sparse(1:n_s,1:n_s,mu./s,n_s,n_s);
    Jh(:,SW.refbus) = 0;
    gx = gy+(Jh.')*(H_m*gmu-mu);
    Jd = [D2xLms+(Jh.')*(H_m*Jh),-Jg.';-Jg,Z3];
    % reference angle for the actual system
    gx(SW.refbus) = 0;
    Jd(SW.refbus,:) = 0;
    Jd(:,SW.refbus) = 0;
    %Jd = Jd + sparse(SW.refbus,SW.refbus,1,n_y+DAE.m,n_y+DAE.m);
    Jd(SW.refbus,SW.refbus) = speye(length(SW.refbus));
    % LU factorization
    [L,U,P] = lu(Jd);
    % variable increments
    Dx = -U\(L\(P*[gx; -DAE.g]));
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
    gx = gy +(Jh.')*(H_m*gmu-gs);
    gx(SW.refbus) = 0;
    % variable increments
    Dx = -U\(L\(P*[gx; -DAE.g]));
    Ds = -(gmu+Jh*Dx([1:n_y]));
    Dm = -gs-H_m*Ds;
  end

  % =======================================================================
  % Variable Increments
  % =======================================================================

  Dy  = Dx(nY);         idx = DAE.m;            % curr. sys.
  DQg = Dx(idx+nG);     idx = idx + n_gen;
  DPs = Dx(idx+nS);     idx = idx + Supply.n;
  DPd = Dx(idx+nD);     idx = idx + Demand.n;
  if Rsrv.n, DPr = Dx(idx+nR);    idx = idx + Rsrv.n;    end
  Dro = Dx(1+idx:end);                          % Lag. mult.

  % =======================================================================
  % Updating the Variables
  % =======================================================================

  % Step Length Parameters [alpha_P & alpha_D]
  %________________________________________________________________________

  a1 = find(Ds < 0);
  a2 = find(Dm < 0);
  if isempty(a1), ratio1 = 1; else, ratio1 = (-s(a1)./Ds(a1));   end
  if isempty(a2), ratio2 = 1; else, ratio2 = (-mu(a2)./Dm(a2)); end
  alpha_P = min(1,gamma*min(ratio1));
  alpha_D = min(1,gamma*min(ratio2));

  % New primal variables
  %________________________________________________________________________

  DAE.y = DAE.y + alpha_P*Dy;
  Ps = Ps + alpha_P*DPs;
  Pd = Pd + alpha_P*DPd;
  Qg = Qg + alpha_P*DQg;
  if Rsrv.n, Pr = Pr + alpha_P*DPr; end
  s = s + alpha_P*Ds;

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
  G_obj = (Fixd_c+Prop_c+Quad_c+Quad_q+TieBreaking+Reserve)-ms*sum(log(s));

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
  norma3 = norm(DAE.g,inf);
  Settings.error = norma3;
  test3  = norma3 <= epsilon_1;
  norma4 = abs(G_obj-G_obj_k_1)/(1+abs(G_obj));
  test4  = norma4 <= epsilon_2;

  if test1 && test2 && test3 && test4, break, end

  % Displaying Convergence Tests
  %________________________________________________________________________

  iteration = iteration + 1;

  fm_status('opf','update',[iteration, ms, norma2, norma3, norma4], ...
            iteration)

  if OPF.show
    fm_disp(['Iter. =',fvar(iteration,5),'  mu =', fvar(ms,8), ...
             '  |dy| =', fvar(norma2,8), '  |f(y)| =', ...
             fvar(norma3,8),'  |dG(y)| =' fvar(norma4,8)])
  end
  if iteration > iter_max, break, end
end

% Updating Demand.con & Supply.con
%____________________________________________________________________________

if Settings.matlab, warning('on'); end

Demand = pset(Demand,Pd);
Supply = pset(Supply,Ps);
Rsrv = pset(Rsrv,Pr);

MVA = Settings.mva;
Pay = ro(Bus.a).*Line.p*MVA;
ISOPay = sum(Pay);
Iij  = sqrt(Iij);
Iji  = sqrt(Iji);
Iijmax  = sqrt(Iijmax);

% Computation of Nodal Congestion Prices (NCPs)
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

SNB.init = 0;
LIB.init = 0;
CPF.init = 0;
OPF.init = 1;

% set Pg, Qg, Pl and Ql
Bus.Pl = OPF.basepl*Snapshot(1).Pl + sparse(Demand.bus,1,Pd,n1,1);
Bus.Ql = OPF.basepl*Snapshot(1).Ql + sparse(Demand.bus,1,Pd.*qonp,n1,1);
Bus.Pg = OPF.basepg*Snapshot(1).Pg + sparse(Supply.bus,1,Ps,n1,1);
Bus.Qg = OPF.basepg*Snapshot(1).Qg + sparse(busG,1,Qg,n1,1);

% Display Results
%____________________________________________________________________________

if (Settings.showlf || OPF.show) && clpsat.showopf

  OPF.report = cell(1,1);
  OPF.report{1,1} = ['TTL = ', ...
                     fvar(sum(Pd)+totp(PQ),8), ' [p.u.]'];
  if ~noDem
    OPF.report{2,1} = ['Total demand = ',fvar(sum(Pd),8), ' [p.u.]'];
  end
  OPF.report{2+(~noDem),1} = ['Bid Losses = ', ...
                      fvar(sum(Line.p)-Snapshot(1).Ploss,8), ' [p.u.]'];
  OPF.report{3+(~noDem),1} = ['Total Losses = ', ...
                      fvar(sum(Line.p),8), ' [p.u.]'];

  fm_disp
  fm_disp('----------------------------------------------------------------')

  Settings.lftime = toc;

  if ishandle(Fig.stat), fm_stat; end

  if iteration > iter_max
    fm_disp('IPM-OPF: Method did not converge',2)
  elseif ishandle(Fig.main)
    if ~get(Fig.main,'UserData')
      fm_disp('IPM-OPF: Interrupted',2)
    else
      fm_disp(['IPM-OPF completed in ',num2str(toc),' s'],1)
    end
  else
    fm_disp(['IPM-OPF completed in ',num2str(toc),' s'],1)
    if Settings.showlf == 1
      fm_stat(OPF.report);
    else
      if Settings.beep, beep, end,
    end
  end
  fm_status('opf','close')
else
  if iteration > iter_max
    fm_disp('IPM-OPF: Method did not converge',2)
  elseif ishandle(Fig.main)
    if ~get(Fig.main,'UserData')
      fm_disp('IPM-OPF: Interrupted',2)
    else
      fm_disp(['IPM-OPF completed in ',num2str(toc),' s'],1)
    end
  else
    fm_disp(['IPM-OPF completed in ',num2str(toc),' s'],1)
  end
end

if iteration > iter_max, OPF.conv = 0; else, OPF.conv = 1; end
if Rsrv.n,
  OPF.guess = [s; mu; DAE.y; Qg; Ps; Pd; Pr; ro];
else
  OPF.guess = [s; mu; DAE.y; Qg; Ps; Pd; ro];
end
OPF.LMP = -ro(1:n1);

if noDem, Demand = restore(Demand); end
Settings.forcepq = forcepq;

if ~OPF.basepl
  PQ = pqreset(PQ,'all');
end
if ~OPF.basepg
  SW = swreset(SW,'all');
  PV = pvreset(PV,'all');
end