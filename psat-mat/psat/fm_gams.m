function fm_gams
% FM_GAMS initialize and call GAMS to solve
%         several kind of Market Clearing Mechanisms
%
% FM_GAMS
%
%GAMS settings are stored in the structure GAMS, with
%the following fields:
%
%      METHOD   1 -> simple auction
%               2 -> linear OPF (DC power flow)
%               3 -> nonlinear OPF (AC power flow)
%               4 -> nonlinear VSC-OPF
%               5 -> maximum loading condition
%               6 -> continuation OPF
%
%      TYPE     1 -> single period auction
%               2 -> multi period auction
%               3 -> VSC single period auction
%               4 -> VSC multi period auction
%
%see also FM_GAMS.GMS, FM_GAMSFIG and
%structures CPF and OPF for futher settings
%
%Author:    Federico Milano
%Date:      29-Jan-2003
%Update:    01-Feb-2003
%Update:    06-Feb-2003
%Version:   1.0.2
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global DAE OPF CPF GAMS Bus File clpsat
global Path Settings Snapshot Varname
global PV PQ SW Line Shunt jay Varout
global Supply Demand Rmpl Rmpg Ypdp

[u,w] = system('gams');
if u
  fm_disp('GAMS is not properly installed on your system.',2)
  return
end

if ~autorun('PSAT-GAMS Interface',0)
  return
end

if DAE.n
  fm_disp(['Dynamic data are not supported within the PSAT-GAMS interface.'],2)
  return
end

if ~Supply.n,
  fm_disp(['Supply data have to be specified before in order to ', ...
	   'run PSAT-GAMS interface'],2)
  return
end

if ~Demand.n,
  if GAMS.basepg && ~clpsat.init
    Settings.ok = 0;
    uiwait(fm_choice(['Exclude (recommended) base generator powers?']))
    GAMS.basepg = ~Settings.ok;
  end
  noDem = 1;
  Demand = add(Demand,'dummy');
else
  noDem = 0;
end

length(Snapshot.y);
if ~GAMS.basepl
  buspl = Snapshot(1).Pl;
  busql = Snapshot(1).Ql;
  Bus.Pl(:) = 0;
  Bus.Ql(:) = 0;
  PQ = pqzero(PQ,'all');
end
if ~GAMS.basepg
  ploss = Snapshot(1).Ploss;
  Snapshot(1).Ploss = 0;
  buspg = Snapshot(1).Pg;
  busqg = Snapshot(1).Qg;
  Bus.Pg(:) = 0;
  Bus.Qg(:) = 0;
  SW = swzero(SW,'all');
  PV = pvzero(PV,'all');
end

fm_disp
fm_disp('---------------------------------------------------------')
fm_disp(' PSAT-GAMS Interface')
fm_disp('---------------------------------------------------------')
fm_disp

tic
method = GAMS.method;
modelstat = 0;
solvestat = 0;

type = GAMS.type;
omega = GAMS.omega;
if GAMS.method == 6 && GAMS.type ~= 1
  fm_disp(['WARNING: Continuation OPF can be run only with Single' ...
	   ' Period Auctions.'])
  fm_disp('Voltage Stability Constrained OPF will be solved.')
  method = 4;
end
if GAMS.method == 6 && GAMS.flow ~= 1
  fm_disp(['WARNING: Continuation OPF can be run only with Current ' ...
           'Limits.'])
  fm_disp('Current limits in transmission lines will be used.')
  GAMS.flow = 1;
end
if GAMS.type == 3 && GAMS.method ~= 4
  fm_disp(['WARNING: Pareto Set Single Period Auction can be run ' ...
           'only for VSC-OPF.'])
  fm_disp( '         Single Period Auction will be solved.')
  fm_disp
  type = 1;
end
if GAMS.type == 3 && length(GAMS.omega) == 1
  fm_disp(['WARNING: Weighting factor is scalar. ', ...
           'Single Period Auction will be solved.'])
  fm_disp
  type = 1;
end
if GAMS.type == 1 && length(GAMS.omega) > 1
  fm_disp(['WARNING: Weighting factor is a vector. ', ...
           'First omega entry will be used.'])
  fm_disp
  omega = omega(1);
end
if ~rem(GAMS.type,2) && ~Rmpg.n
  type = 1;
  fm_disp(['WARNING: No Ramping data were found. ', ...
           'Single Period Auction will be solved.'])
  fm_disp
end
if GAMS.type == 2 && Rmpg.n && ~Ypdp.n
  type = 4;
  fm_disp(['WARNING: No Power Demand Profile was found. Single ' ...
           'Period Auction with Unit Commitment will be solved.'])
  fm_disp
end

% resetting time vector in case of previous time simulations
if type == 3, Varout.t = []; end

switch method
 case 1, fm_disp(' Simple Auction')
 case 2, fm_disp(' Market Clearing Mechanism')
 case 3, fm_disp(' Standard OPF')
 case 4, fm_disp(' Voltage Stability Constrained OPF')
 case 5, fm_disp(' Maximum Loading Condition')
 case 6, fm_disp(' Continuation OPF')
 case 7, fm_disp(' Congestion Management')
end

switch type
 case 1, fm_disp(' Single-Period Auction')
 case 2, fm_disp(' Multi-Period Auction')
 case 3, fm_disp(' Pareto Set Single-Period Auction')
 case 4, fm_disp(' Single-Period Auction with Unit Commitment')
end

if (GAMS.flatstart || isempty(Snapshot)) && GAMS.method > 2
  DAE.y(Bus.a) = getzeros(Bus);
  DAE.y(Bus.v) = getones(Bus);
else
  DAE.y = Snapshot(1).y;
end

% ------------------------------------------------------------
% Parameter definition
% ------------------------------------------------------------

% dimensions
nBus = int2str(Bus.n);
nQg = int2str(PV.n+SW.n);
nBusref = int2str(SW.refbus);

[nSW,SW_idx,ksw] = gams(SW);
[nPV,PV_idx,kpv] = gams(PV);
[nLine,L,Li,Lj,Gh,Bh,Ghc,Bhc] = gams(Line,method);
[Gh,Bh,Ghc,Bhc] = gams(Shunt,method,Gh,Bh,Ghc,Bhc);
[nPd,Pd_idx,D] = gams(Demand);
[nPs,Ps_idx,S] = gams(Supply,type);
[nH,Ch] = gams(Ypdp,type);

% indexes
iBPs = Supply.bus;
iBPd = Demand.bus;
iBQg = [SW.bus; PV.bus];

% Fixed powers
Pg0 = Bus.Pg;
Pl0 = Bus.Pl;
Ql0 = Bus.Ql;

% Generator reactive powers and associated limits
Qg0 = getzeros(Bus);
Qg0(iBQg) = Bus.Qg(iBQg);
[Qgmax,Qgmin] = fm_qlim('all');

% Voltage limits
V0 = DAE.y(Bus.v);
t0 = DAE.y(Bus.a);
[Vmax,Vmin] = fm_vlim(1.5,0.2);

% ------------------------------------------------------------
% Data structures
% ------------------------------------------------------------

X.val = [V0,t0,Pg0,Qg0,Pl0,Ql0,Qgmax,Qgmin,Vmax,Vmin,ksw,kpv];
lambda.val = [GAMS.lmin(1),GAMS.lmax(1),GAMS.omega(1),GAMS.line];

X.labels = {cellstr(num2str(Bus.a)), ...
	    {'V0','t0','Pg0','Qg0','Pl0','Ql0', ...
	     'Qgmax','Qgmin','Vmax','Vmin','ksw','kpv'}};
lambda.labels = {'lmin','lmax','omega','line'};

X.name = 'X';
lambda.name = 'lambda';

% ------------------------------------------------------------
% Launch GAMS solver
% ------------------------------------------------------------

control = int2str(method);
flow = int2str(GAMS.flow);
currentpath = pwd;
file = 'fm_gams';
if ~rem(type,2)
  file = [file,'2'];
end
if GAMS.libinclude
  file = [file,' ',GAMS.ldir];
end

if clpsat.init || ispc, cd(Path.psat), end

switch control

 % ------------------------------------------------------------------
 case '1' % S I M P L E   A U C T I O N
 % ------------------------------------------------------------------

  if type == 1 % Single Period Auction
    [Ps,Pd,MCP,modelstat,solvestat] = psatgams(file,nBus,nLine,nPs,nPd,nSW,nPV, ...
                       nBusref,control,flow,S,D,X);
    [Pij,Pji,Qg] = updatePF(Pd,Ps,iBQg);

  elseif ~rem(type,2) % Single/Multi Period Auction with UC
    [Ps,Pd,MCP,modelstat,solvestat] = psatgams(file,nBus,nLine,nPs,nPd,nSW,nPV, ...
                       nBusref,nH,control,flow,S,D,X,Ch);
    numh = size(MCP,1);
    a = zeros(numh,Bus.n);
    V = zeros(numh,Bus.n);
    Qg = zeros(numh,Bus.n);
    Pij = zeros(numh,Line.n);
    Qij = zeros(numh,Line.n);
    for i = 1:numh
      [Piji,Pjii,Qgi] = updatePF(Pd(i,:)',Ps(i,:)',iBQg);
      a(i,:) = [DAE.y(Bus.a)]';
      V(i,:) = [DAE.y(Bus.v)]';
      Pij(i,:) = Piji';
      Pji(i,:) = Pjii';
      Qg(i,iBQg) = Qgi';
    end
    ro = MCP*ones(1,Bus.n);

  end

 % ------------------------------------------------------------------
 case '2' % M A R K E T   C L E A R I N G   M E C H A N I S M
 % ------------------------------------------------------------------

  if type == 1 % Single Period Auction
    [Ps,Pd,MCP,modelstat,solvestat] = psatgams(file,nBus, ...
                       nLine,nPs,nPd,nSW,nPV,nBusref,control, ...
                       flow,Gh,Bh,Li,Lj,Ps_idx,Pd_idx,SW_idx,PV_idx, ...
                       S,D,X,L);
    [Pij,Pji,Qg] = updatePF(Pd,Ps,iBQg);
  elseif ~rem(type,2) % Single/Multi Period Auction with UC
    [Ps,Pd,MCP,modelstat,solvestat] = psatgams(file,nBus, ...
                       nLine,nPs,nPd,nSW,nPV,nBusref,nH,control, ...
                       flow,Gh,Bh,Li,Lj,Ps_idx,Pd_idx,SW_idx,PV_idx, ...
                       S,D,X,L,Ch);
    numh = size(MCP,1);
    a = zeros(numh,Bus.n);
    V = zeros(numh,Bus.n);
    Qg = zeros(numh,Bus.n);
    Pij = zeros(numh,Line.n);
    Qij = zeros(numh,Line.n);
    for i = 1:numh
      [Piji,Pjii,Qgi] = updatePF(Pd(i,:)',Ps(i,:)',iBQg);
      a(i,:) = [DAE.y(Bus.a)]';
      V(i,:) = [DAE.y(Bus.v)]';
      Pij(i,:) = Piji';
      Pji(i,:) = Pjii';
      Qg(i,iBQg) = Qgi';
    end
    ro = MCP;

  end

 % ------------------------------------------------------------------
 case '3' % S T A N D A R D   O P T I M A L   P O W E R   F L O W
 % ------------------------------------------------------------------

  if type == 1 % Single Period Auction

    [Ps,Pd,V,a,Qg,ro,Pij,Pji,mV,mFij,mFji,modelstat,solvestat] = ...
        psatgams(file,nBus,nLine,nPs,nPd,nSW,nPV,nBusref,control, ...
             flow,Gh,Bh,Li,Lj,Ps_idx,Pd_idx,S,D,X,L);
    NCP = compNCP(V,a,mV,mFij,mFji);

  elseif ~rem(type,2) % Single/Multi Period Auction with UC

    [Ps,Pd,V,a,Qg,ro,Pij,Pji,mV,mFij,mFji,modelstat,solvestat] = ...
        psatgams(file,nBus,nLine,nPs,nPd,nSW,nPV,nBusref,nH,control, ...
             flow,Gh,Bh,Li,Lj,Ps_idx,Pd_idx,S,D,X,L,Ch);

    NCP = zeros(length(Ps(:,1)),Bus.n);
    for i = 1:length(Ps(:,1))
      NCPi = compNCP(V(i,:)',a(i,:)',mV(i,:)',mFij(i,:)',mFji(i,:)');
      NCP(i,:) = NCPi';
    end

  end

 % ------------------------------------------------------------------
 case '7' % C O N G E S T I O N   M A N A G E M E N T
 % ------------------------------------------------------------------

  %lambda_values = [0.0:0.01:0.61];
  %n_lambda = length(lambda_values);
  %GAMS.dpgup = zeros(Supply.n,n_lambda);
  %GAMS.dpgdw = zeros(Supply.n,n_lambda);
  %GAMS.dpdup = zeros(Demand.n,n_lambda);
  %GAMS.dpddw = zeros(Demand.n,n_lambda);
  %for i = 1:length(lambda_values)
  %lambda.val(1) = lambda_values(i);

  iteration = 0;

  idx_gen = zeros(Supply.n,1);
  Psc_idx = Ps_idx;
  Psm_idx = zeros(Bus.n,Supply.n);

  while 1
    [Ps,Pd,dPSup,dPSdw,dPDup,dPDdw,V,a,Qg,ro,Pij,Pji,mV,mFij,mFji, ...
     lambdac,kg,Vc,ac,Qgc,Pijc,Pjic,Pceq,lambdam,modelstat,solvestat] = ...
        psatgams('fm_cong',nBus,nLine,nPs,nPd,nBusref,nSW,nPV,control,flow, ...
                 Gh,Bh,Ghc,Bhc,Li,Lj,Ps_idx,Psc_idx,Psm_idx,Pd_idx, ...
                 SW_idx,PV_idx,S,D,X,L,lambda);

    iteration = iteration + 1;
    if iteration > 10
      fm_disp('* * * Maximum number of iteration with no convergence!')
      break
    end
    idx = psupper(Supply,(1+lambdac+kg)*Ps);
    if sum(idx_gen(idx)) == length(idx)
      fm_disp(['* * * iter = ',num2str(iteration), ...
               ', #viol., ',num2str(length(find(idx_gen))), ...
               ' lambda = ', num2str(lambdac), ...
               ' kg = ', num2str(kg)])
      break
    else
      % loop until there are no violations of power supply limits
      idx_gen(idx) = 1;
      fm_disp(['* * * iter = ',num2str(iteration),', #viol. = ', ...
               num2str(length(idx)),', lambda = ', ...
               num2str(lambdac),' kg = ', num2str(kg)])
      drawnow;
      Psc_idx = psidx(Supply,~idx_gen);
      Psm_idx = psidx(Supply,idx_gen);

    end
  end

  %GAMS.dpgup(:,i) = dPSup;
  %GAMS.dpgdw(:,i) = dPSdw;
  %GAMS.dpdup(:,i) = dPDup;
  %GAMS.dpddw(:,i) = dPDdw;
  %if ~rem(i,10), disp(['Current lambda = ',num2str(lambda_values(i))]),end
  %end
  %GAMS.lvals = lambda_values;
  NCP = compNCP(V,a,mV,mFij,mFji);


 % ------------------------------------------------------------------
 case '4' % V O L T A G E   S T A B I L I T Y   C O N S T R A I N E D
          % O P T I M A L   P O W E R    F L O W
 % ------------------------------------------------------------------

  if type == 1 % Single Period Auction
    [Ps,Pd,V,a,Qg,ro,Pij,Pji,mV,mFij,mFji, ...
     lambdac,kg,Vc,ac,Qgc,Pijc,Pjic,Pceq,modelstat,solvestat] = ...
        psatgams(file,nBus,nLine,nPs,nPd,nBusref,nSW,nPV,control,flow, ...
                 Gh,Bh,Ghc,Bhc,Li,Lj,Ps_idx,Pd_idx,SW_idx,PV_idx,S,D,X,L,lambda);
    NCP = compNCP(V,a,mV,mFij,mFji);

  elseif ~rem(type,2) % Single/Multi Period Auction with UC

    [Ps,Pd,V,a,Qg,ro,Pij,Pji,mV,mFij,mFji, ...
     lambdac,kg,Vc,ac,Qgc,Pijc,Pjic,Pceq,modelstat,solvestat] = ...
        psatgams(file,nBus,nLine,nPs,nPd,nBusref,nH,control,flow, ...
                 Gh,Bh,Ghc,Bhc,Li,Lj,Ps_idx,Pd_idx,S,D,X,L,lambda,Ch);

    NCP = zeros(length(lambdac),Bus.n);
    for i = 1:length(lambdac)
      NCPi = compNCP(V(i,:)',a(i,:)',mV(i,:)',mFij(i,:)',mFji(i,:)');
      NCP(i,:) = NCPi';
    end

  elseif type == 3 % Pareto Set Single Period Auction

    fm_disp
    for i = 1:length(omega)
      fm_disp(sprintf(' VSC-OPF #%d, %3.1f%% - omega: %5.4f', ...
		      i,100*i/length(omega),omega(i)))
      lambda.val = [GAMS.lmin(1),GAMS.lmax(1),omega(i),GAMS.line];

      [Psi,Pdi,Vi,ai,Qgi,roi,Piji,Pjii,mV,mFij,mFji, ...
       lambdaci,kgi,Vci,aci,Qgci,Pijci,Pjici,Pceq,modelstat,solvestat] = ...
          psatgams(file,nBus,nLine,nPs,nPd,nBusref,nSW,nPV,control,flow, ...
                   Gh,Bh,Ghc,Bhc,Li,Lj,Ps_idx,Pd_idx,SW_idx,PV_idx, ...
                   S,D,X,L,lambda);
      gams_mstat(modelstat)
      gams_sstat(solvestat)

      Ps(i,:) = Psi';
      Pd(i,:) = Pdi';
      V(i,:) = Vi';
      a(i,:) = ai';
      Qg(i,:) = Qgi';
      ro(i,:) = roi';
      Pij(i,:) = Piji';
      Pji(i,:) = Pjii';
      lambdac(i,:) = lambdaci';
      kg(i,:) = kgi';
      Vc(i,:) = Vci';
      ac(i,:) = aci';
      Qgc(i,:) = Qgci';
      Pijc(i,:) = Pijci';
      Pjic(i,:) = Pjici';
      NCPi = compNCP(Vi,ai,mV,mFij,mFji);
      NCP(i,:) = NCPi';

    end
    fm_disp
  end

 % ------------------------------------------------------------------
 case '5' % M A X I M U M   L O A D I N G   C O N D I T I O N
 % ------------------------------------------------------------------

  if type == 1 % Single Period Auction

    [Ps,Pd,V,a,Qg,ro,Pij,Pji,lambdac,kg,modelstat,solvestat] = ...
        psatgams(file,nBus,nLine,nPs,nPd,nSW,nPV,nBusref, ...
		 control,flow,Gh,Bh,Li,Lj,Ps_idx,Pd_idx, ...
                 SW_idx,PV_idx,S,D,X,L);

  elseif  ~rem(type,2) % Single/Multi Period Auction with UC

    [Ps,Pd,V,a,Qg,ro,Pij,Pji,lambdac,kg,modelstat,solvestat] = ...
        psatgams(file,nBus,nLine,nPs,nPd,nSW,nPV,nBusref,nH, ...
		 control,flow,Gh,Bh,Li,Lj,Ps_idx,Pd_idx,SW_idx, ...
                 PV_idx,S,D,X,L,Ch);

  end

 % ------------------------------------------------------------------
 case '6' % C O N T I N U A T I O N
          % O P T I M A L   P O W E R    F L O W
 % ------------------------------------------------------------------

  initial_time = clock;
  if type == 1 % single period OPF, no discrete variables

    % number of steps
    i = 0;
    last_point = 0;
    % initial lambda = 0. Base case has to be feasible
    lmin = 0;
    lmax = 0;
    Lambda = lmin;
    % save actual CPF settings
    CPF_old = CPF;
    %CPF.nump = 50;
    CPF.show = 0;
    CPF.type = 3;
    CPF.sbus = 0;
    CPF.vlim = 1;
    CPF.ilim = 1;
    CPF.qlim = 1;
    CPF.init = 0;
    CPF.step = 0.25;
    control = '6';

    % save actual power flow data
    % ------------------------------------------------------
    snappg = Snapshot(1).Pg;
    %Snapshot(1).Pg = [];
    Bus_old = Bus;

    % defining voltage limits
    [Vmax,Vmin] = fm_vlim(1.2,0.8);

    fm_disp
    stop_opf = 0;

    while 1

      % OPF step
      % ------------------------------------------------------
      i = i + 1;
      fm_disp(sprintf('Continuation OPF #%d, lambda_c = %5.4f', ...
		      i,lmin))
      lambda.val = [lmin,lmax,0,GAMS.line];

      % call GAMS
      [Psi,Pdi,Vi,ai,Qgi,roi,Piji,Pjii,mV,mFij,mFji, ...
       lambdaci,kgi,Vci,aci,Qgci,Pijci,Pjici,mPceq,ml,modelstat,solvestat] = ...
        psatgams(file,nBus,nLine,nPs,nPd,nBusref,nSW,nPV,control,flow, ...
             Gh,Bh,Ghc,Bhc,Li,Lj,Ps_idx,Pd_idx,SW_idx,PV_idx,S,D,X,L,lambda);
      gams_mstat(modelstat)
      gams_sstat(solvestat)

      Lambda(i,1) = lambdaci;
      Ps(i,:) = Psi';
      Pd(i,:) = Pdi';
      V(i,:) = Vi';
      a(i,:) = ai';
      Qg(i,:) = Qgi';
      ro(i,:) = roi';
      Pij(i,:) = Piji';
      Pji(i,:) = Pjii';
      lambdac(i,:) = lambdaci;
      kg(i,:) = kgi;
      Vc(i,:) = Vci';
      ac(i,:) = aci';
      Qgc(i,:) = Qgci';
      Pijc(i,:) = Pijci';
      Pjic(i,:) = Pjici';
      NCPi = compNCP(Vi,ai,mV,mFij,mFji);
      NCP(i,:) = NCPi';
      ML(i,1) = ml;

      % check consistency of the solution (LMP > 0)
      if modelstat > 3 %min(abs(roi)) < 1e-5

        fm_disp('Unfeasible OPF solution. Discarding last solution.')
        Lambda(end) = [];
        Ps(end,:) = [];
        Pd(end,:) = [];
        V(end,:) = [];
        a(end,:) = [];
        Qg(end,:) = [];
        ro(end,:) = [];
        Pij(end,:) = [];
        Pji(end,:) = [];
        lambdac(end) = [];
        kg(end) = [];
        Vc(end,:) = [];
        ac(end,:) = [];
        Qgc(end,:) = [];
        Pijc(end,:) = [];
        Pjic(end,:) = [];
        NCP(end,:) = [];
        ML(end) = [];
        lambdaci = lambdac(end,:);
        break

      end

      % ------------------------------------------------------
      % Bid variations to allow loading parameter increase
      %
      %                      d mu_Pceq_i
      % D P_i = -sign(P_i)  -------------
      %                      d mu_lambda
      %
      % where:
      %
      % P_i = power bid i
      % mu_Pceq_i = Lagrangian multiplier of critical PF eq. i
      % mu_lambda = Lagrangian multiplier of lambda
      % ------------------------------------------------------

      delta = 0.05;

      while 1

        if abs(ml) > 1e-5
          deltaPd =  ml./mPceq(Demand.bus)/(1+lambdaci);
          deltaPs = -ml./mPceq(Supply.bus)/(1+lambdaci+kgi);
          delta_max = norm([deltaPs; deltaPd]);
          if delta_max == 0, delta_max = 1; end
          deltaPd = deltaPd/delta_max;
          deltaPs = deltaPs/delta_max;
        else
          deltaPd = zeros(Demand.n,1);
          deltaPs = zeros(Supply.n,1);
        end
        %ml
        %mPceq
        %delta_max = max(norm([deltaPs; deltaPd]));
        %if delta_max == 0, delta_max = 1; end
        DPs(i,:) = deltaPs'/Settings.mva;
        DPd(i,:) = deltaPd'/Settings.mva;

        Pdi = pdbound(Demand,Pd(i,:)' + delta*deltaPd.*Pd(i,:)');
        Psi = psbound(Supply,Ps(i,:)' + delta*deltaPs.*Ps(i,:)');

        % CPF step
        % ------------------------------------------------------
        if GAMS.basepl
          PQ = pqreset(PQ,'all');
          PV = pvreset(PV,'all');
          SW = swreset(SW,'all');
          Snapshot(1).Pg = snappg;
        else
          PQ = pqzero(PQ,'all');
          PV = pvzero(PV,'all');
          SW = swzero(SW,'all');
          Snapshot(1).Pg = getzeros(Bus);
        end

        Demand = pset(Demand,Pdi);
        pqsum(Demand,1);
        Supply = pset(Supply,Psi);
        pgsum(Supply,1);
        swsum(Supply,1);

        DAE.y(Bus.a) = aci;
        DAE.y(Bus.v) = Vci;
        PV = setvg(PV,'all',DAE.y(PV.vbus));
        SW = setvg(SW,'all',DAE.y(SW.vbus));
        DAE.x = Snapshot(1).x;
        Bus.Pg = Bus_old.Pg;
        Bus.Qg = Bus_old.Qg;
        Bus.Pl = Bus_old.Pl;
        Bus.Ql = Bus_old.Ql;

        % avoid aborting CPF routine due to limits
        % ------------------------------------------------------

        % voltage limits
        Vbus = DAE.y(Bus.v);
        idx = find(abs(Vbus-Vmax) < CPF.tolv | Vbus > Vmax);
        if ~isempty(idx)
          DAE.y(idx+Bus.n) = Vmax(idx)-1e-6-CPF.tolv;
        end
        idx = find(abs(Vbus-Vmin) < CPF.tolv | Vbus < Vmin);
        if ~isempty(idx)
          DAE.y(idx+Bus.n) = Vmin(idx)+1e-6+CPF.tolv;
        end

        CPF.kg = 0;
        CPF.lambda = 1; %lambdaci + 1;
        CPF.linit = 1+lambdaci*0.25;
        CPF.init = 0;

        % set contingency for CPF analysis
        if GAMS.line
          status = Line.u(GAMS.line);
          Line = setstatus(Line,GAMS.line,0);
        end

        % ---------------------------------------------
        % call continuation power flow routine
        fm_cpf('gams');
        %CPF.lambda = CPF.lambda + 1;
        % ---------------------------------------------

        % reset admittance line
        if GAMS.line
          Line = setstatus(Line,GAMS.line,status);
        end

        if isempty(CPF.lambda)
          fm_disp([' * CPF solution: <empty>'])
        elseif isnan(CPF.lambda)
          fm_disp([' * CPF solution: <NaN>'])
        else
          fm_disp([' * CPF solution: ',num2str(CPF.lambda-1)])
        end

        if isnan(CPF.lambda)
          stop_opf = 1;
          break
        end
        if isempty(CPF.lambda)
          stop_opf = 1;
          break
        end
        if CPF.lambda ~= lambdaci
          CPF.lambda = CPF.lambda - 0.995;
        end

        if CPF.lambda < lambdaci && abs(ml) <= 1e-5
          ml = 0;
          CPF.lambda = lmin+1e-5;
        end
        if CPF.lambda < lmin && abs(ml) > 1e-5
          fm_disp([' * Decrease Delta Ps and Delta Pd'])
          delta = 0.5*delta;
          if delta < 5e-8
            fm_disp([' * CPF method cannot find a higher lambda'])
            stop_opf = 1;
            break
          end
          repeat_cpf = 1;
        else
          repeat_cpf = 0;
        end

        % maximum lambda increment
        if (CPF.lambda - lmin) > 0.025 % && (abs(ml) > 1e-5 || CPF.lambda > 0.6)
          fm_disp(['lambda critical = ',num2str(CPF.lambda)])
          fm_disp(['Limit lambda increment to threshold (0.025)'])
          CPF.lambda = lmin + 0.025;
        end

        % stopping criterion
        % ------------------------------------------------------
        if last_point
          fm_disp('Reached maximum lambda.')
          if CPF.lambda > lmin
            fm_disp('Desired maximum lambda is not critical.')
          end
          stop_opf = 1;
          break
        end
        if i >= CPF.nump
          fm_disp('Reached maximum # of continuation steps.')
          stop_opf = 1;
          break
        end
        if CPF.lambda >= GAMS.lmax
          CPF.lambda = GAMS.lmax;
          last_point = 1;
        end
        if CPF.lambda == 0
          fm_disp('Base case solution is likely unfeasible.')
          stop_opf = 1;
          break
        end
        if abs(lmin-CPF.lambda) < 1e-5
          %fm_disp(['||lambda(i+1) - lambda(i)|| = ', ...
          %         num2str(abs(lmin-CPF.lambda))])
          fm_disp('Lambda increment is lower than the desired tolerance.')
          stop_opf = 1;
          break
        elseif ~repeat_cpf
          if abs(ml) < 1e-5
            lmin = CPF.lambda+0.001;
            lmax = CPF.lambda+0.001;
          else
            lmin = CPF.lambda;
            lmax = CPF.lambda;
          end
          break
        end
      end
      %end
      if stop_opf, break, end
    end

    % restore original data and settings
    % --------------------------------------------------------
    DAE.y = Snapshot(1).y;
    Snapshot(1).Pg = snappg;
    Bus.Pg = Bus_old.Pg;
    Bus.Qg = Bus_old.Qg;
    Bus.Pl = Bus_old.Pl;
    Bus.Ql = Bus_old.Ql;
    PV = restore(PV);
    SW = restore(SW);
    PQ = pqreset(PQ,'all');

    CPF = CPF_old;
    CPF.init = 4;

    Varout.t = [];
    Varout.vars = [];

    fm_disp
    % uncomment to plot [dP/d lambda] instead of [P]
    %Ps = DPs;
    %Pd = DPd;

  else

    fm_disp('Continuation OPF not implemented yet...')
    cd(currentpath)
    return

  end

end

% -------------------------------------------------------------------
% Output
% -------------------------------------------------------------------
MVA = Settings.mva;
TPQ = MVA*totp(PQ);

% character for backslash
bslash = char(92);

if GAMS.method == 6, type = 3; end

if type == 2 || type == 3

  switch GAMS.flow
   case 0, flow = 'I_';
   case 1, flow = 'I_';
   case 2, flow = 'P_';
   case 3, flow = 'S_';
  end

  Lf = cellstr(num2str(Line.fr));
  Lt = cellstr(num2str(Line.to));

  TD = MVA*sum(Pd')';

  if type == 2
    TD = MVA*sum(Pd,2);
    TTL = TD + TPQ*Ch.val';
    TL = MVA*sum(Ps')' + MVA*sum(Bus.Pg)*Ch.val' - TTL;
    TBL = TL - MVA*Snapshot(1).Ploss*Ch.val';
    for i = 1:size(Ps,1)
      PG(i,:) = full(sparse(1,iBPs,Ps(i,:),1,Bus.n)+Ch.val(i)*Bus.Pg')*MVA;
    end
    for i = 1:size(Pd,1)
      PL(i,:) = full(sparse(1,iBPd,Pd(i,:),1,Bus.n)+Ch.val(i)*Bus.Pl')*MVA;
    end
  elseif type == 3
    TTL = TD + TPQ;
    TL = MVA*sum(Ps')' + MVA*sum(Bus.Pg) - TTL;
    TBL = TL - MVA*Snapshot(1).Ploss;
    for i = 1:size(Ps,1)
      PG(i,:) = full(sparse(1,iBPs,Ps(i,:),1,Bus.n)+Bus.Pg')*MVA;
    end
    for i = 1:size(Pd,1)
      PL(i,:) = full(sparse(1,iBPd,Pd(i,:),1,Bus.n)+Bus.Pl')*MVA;
    end
  end
  PayS = -PG.*ro;
  PayD = PL.*ro;
  ISO = sum(PayS')'+sum(PayD')';
  if GAMS.method == 4 || GAMS.method == 6
    MLC = TTL.*(1+lambdac);
  elseif GAMS.method == 5
    MLC = TTL.*lambdac;
  end

  Varname.uvars = fm_strjoin('PS_',{Bus.names{Supply.bus}}');
  Varname.uvars = [Varname.uvars;fm_strjoin('PD_',{Bus.names{Demand.bus}}')];
  Varname.uvars = [Varname.uvars;fm_strjoin('PG_',{Bus.names{:}}')];
  Varname.uvars = [Varname.uvars;fm_strjoin('PL_',{Bus.names{:}}')];
  Varname.uvars = [Varname.uvars;fm_strjoin('Pay_S_',{Bus.names{:}}')];
  Varname.uvars = [Varname.uvars;fm_strjoin('Pay_D_',{Bus.names{:}}')];
  Varname.uvars = [Varname.uvars;fm_strjoin('theta_',{Bus.names{:}}')];
  Varname.uvars = [Varname.uvars;fm_strjoin('V_',{Bus.names{:}}')];
  Varname.uvars = [Varname.uvars;fm_strjoin('Qg_',{Bus.names{iBQg}}')];
  if GAMS.method > 2 && GAMS.method ~= 5
    Varname.uvars = [Varname.uvars;fm_strjoin('LMP_',{Bus.names{:}}')];
    Varname.uvars = [Varname.uvars;fm_strjoin('NCP_',{Bus.names{:}}')];
  elseif GAMS.method == 2
    Varname.uvars = [Varname.uvars;fm_strjoin('LMP_',{Bus.names{:}}')];
  elseif GAMS.method == 5
    Varname.uvars = [Varname.uvars;fm_strjoin(bslash,'rho_',{Bus.names{:}}')];
  else
    Varname.uvars = [Varname.uvars;{'MCP'}];
  end
  Varname.uvars = [Varname.uvars;fm_strjoin(flow,Lf,'-',Lt)];
  Varname.uvars = [Varname.uvars;fm_strjoin(flow,Lt,'-',Lf)];
  Varname.uvars = [Varname.uvars;{'Total Demand';'TTL';'Total Losses'; ...
                      'Total Bid Losses';'IMO Pay'}];
  if GAMS.method >= 4
    Varname.uvars = [Varname.uvars;{'MLC'}];
    Varname.uvars = [Varname.uvars;{'ALC'}];
  end

  Varname.fvars = fm_strjoin('P_{S',{Bus.names{Supply.bus}}','}');
  Varname.fvars = [Varname.fvars;fm_strjoin('P_{D',{Bus.names{Demand.bus}}','}')];
  Varname.fvars = [Varname.fvars;fm_strjoin('P_{G',{Bus.names{:}}','}')];
  Varname.fvars = [Varname.fvars;fm_strjoin('P_{L',{Bus.names{:}}','}')];
  Varname.fvars = [Varname.fvars;fm_strjoin('Pay_{S',{Bus.names{:}}','}')];
  Varname.fvars = [Varname.fvars;fm_strjoin('Pay_{D',{Bus.names{:}}','}')];
  Varname.fvars = [Varname.fvars;fm_strjoin(bslash,'theta_{',{Bus.names{:}}','}')];
  Varname.fvars = [Varname.fvars;fm_strjoin('V_{',{Bus.names{:}}','}')];
  Varname.fvars = [Varname.fvars;fm_strjoin('Q_{g',{Bus.names{iBQg}}','}')];
  if GAMS.method > 2  && GAMS.method ~= 5
    Varname.fvars = [Varname.fvars;fm_strjoin('LMP_{',{Bus.names{:}}','}')];
    Varname.fvars = [Varname.fvars;fm_strjoin('NCP_{',{Bus.names{:}}','}')];
  elseif GAMS.method == 2
    Varname.fvars = [Varname.fvars;fm_strjoin('LMP_{',{Bus.names{:}}','}')];
  elseif GAMS.method == 5
    Varname.fvars = [Varname.fvars;fm_strjoin(bslash,'rho_',{Bus.names{:}}')];
  else
    Varname.fvars = [Varname.fvars;{'MCP'}];
  end
  Varname.fvars = [Varname.fvars;fm_strjoin(flow,'{',Lf,'-',Lt,'}')];
  Varname.fvars = [Varname.fvars;fm_strjoin(flow,'{',Lt,'-',Lf,'}')];
  Varname.fvars = [Varname.fvars;{'Total Demand';'TTL';'Total Losses'; ...
                   'Total Bid Losses';'IMO Pay'}];
  if GAMS.method >= 4
    Varname.fvars = [Varname.fvars;{'MLC'}];
    Varname.fvars = [Varname.fvars;{'ALC'}];
  end

  switch GAMS.method
   case 3 % OPF

    Varout.vars = [Ps*MVA,Pd*MVA,PG,PL,PayS,PayD,a,V,Qg(:,iBQg)*MVA, ...
                  ro,NCP,Pij,Pji,TD,TTL,TL,TBL,ISO];

   case {4,6} % VSC-OPF

    Varname.uvars = [Varname.uvars;{'lambda_c';'kg_c'}];
    Varname.uvars = [Varname.uvars;fm_strjoin('thetac_',{Bus.names{:}}')];
    Varname.uvars = [Varname.uvars;fm_strjoin('Vc_',{Bus.names{:}}')];
    Varname.uvars = [Varname.uvars;fm_strjoin('Qgc_',{Bus.names{iBQg}}')];
    Varname.uvars = [Varname.uvars;fm_strjoin(flow,'c',Lf,'-',Lt)];
    Varname.uvars = [Varname.uvars;fm_strjoin(flow,'c',Lt,'-',Lf)];

    Varname.fvars = [Varname.fvars;{[bslash,'lambda_c'];'k_g_c'}];
    Varname.fvars = [Varname.fvars;fm_strjoin(bslash,'theta_{c',{Bus.names{:}}','}')];
    Varname.fvars = [Varname.fvars;fm_strjoin('V_{c',{Bus.names{:}}','}')];
    Varname.fvars = [Varname.fvars;fm_strjoin('Q_{gc',{Bus.names{iBQg}}','}')];
    Varname.fvars = [Varname.fvars;fm_strjoin(flow,'{c',Lf,'-',Lt,'}')];
    Varname.fvars = [Varname.fvars;fm_strjoin(flow,'{c',Lt,'-',Lf,'}')];

    Varout.vars = [Ps*MVA,Pd*MVA,PG,PL,PayS,PayD,a,V,Qg(:,iBQg)*MVA, ...
                  ro,NCP,Pij,Pji,TD,TTL,TL,TBL,ISO,MLC,MLC-TTL,lambdac,kg, ...
                  ac,Vc,Qgc(:,iBQg)*MVA,Pijc,Pjic];

   case 5 % MLC

    Varname.uvars = [Varname.uvars;{'lambda_c';'kg_c'}];
    Varname.fvars = [Varname.fvars;{bslash,'lambda_c';'k_g_c'}];
    Varout.vars = [Ps*MVA,Pd*MVA,PG,PL,PayS,PayD,a,V,Qg(:,iBQg)*MVA, ...
                  ro,Pij,Pji,TD,TTL,TL,TBL,ISO,MLC,lambdac,kg];

   otherwise % SA and MCM
    Varout.vars = [Ps*MVA,Pd*MVA,PG,PL,PayS,PayD,a,V,Qg(:,iBQg)*MVA, ...
                  MCP,Pij,Pji,TD,TTL,TL,TBL,ISO];

  end

  if GAMS.method == 6 % Continuation OPF
    Settings.xlabel = [bslash,'lambda (loading parameter)'];
    Varout.t = Lambda';
  elseif type == 2 % Multi Period Auction
    Varout.vars = Varout.vars([2:end],:);
    Settings.xlabel = 'hour [h]';
    Varout.t = [1:Ypdp.len]';
  elseif type == 3 % Pareto Set Single Period Auction
    Settings.xlabel = [bslash,'omega (weighting factor)'];
    Varout.t = GAMS.omega';
  end

  Varout.idx = [1:length(Varout.vars(1,:))];

  fm_disp(' ---------------------------------------------------------------')
  fm_disp([' Check file ',Path.psat,'fm_gams.lst for GAMS report.'])
  if strcmp(control,'6')
    fm_disp([' PSAT-GAMS Optimization Routine completed in ', ...
             num2str(etime(clock,initial_time)),' s'])
  else
    fm_disp([' PSAT-GAMS Optimization Routine completed in ',num2str(toc),' s'])
  end

  Demand = restore(Demand);

  if ~GAMS.basepl
    Bus.Pl = buspl;
    Bus.Ql = busql;
    PQ = pqreset(PQ,'all');
  end
  if ~GAMS.basepg
    Snapshot(1).Ploss = ploss;
    Bus.Pg = buspg;
    Bus.Qg = busqg;
    PV = pvreset(PV,'all');
  end

  % restore original bus power injections
  Bus.Pg = Snapshot(1).Pg;
  Bus.Qg = Snapshot(1).Qg;
  Bus.Pl = Snapshot(1).Pl;
  Bus.Ql = Snapshot(1).Ql;

  return

end

if type == 4

  Ps = Ps(2,:)';
  Pd = Pd(2,:)';
  V = V(2,:)';
  a = a(2,:)';
  Qg = Qg(2,iBQg)';
  Pij = Pij(2,:)';
  Pji = Pji(2,:)';
  if GAMS.method <= 2
    MCP = MCP(2,:);
  end
  if GAMS.method >= 3
    ro = ro(2,:)';
    if GAMS.method ~= 5
      NCP = NCP(2,:)';
    end
  end
  if GAMS.method == 4 || GAMS.method == 6
    Vc = Vc(2,:)';
    ac = ac(2,:)';
    Qgc = Qgc(2,iBQg)';
    Pijc = Pijc(2,:)';
    Pjic = Pjic(2,:)';
  end
  if GAMS.method >= 4
    lambdac = lambdac(2);
    kg = kg(2);
  end
end

Demand = pset(Demand,Pd);
Supply = pset(Supply,Ps);

if GAMS.method == 4 || GAMS.method == 6
  DAE.y(Bus.a) = ac;
  DAE.y(Bus.v) = Vc;
  Line = gcall(Line);
  glfpc = Line.p;
  glfqc = Line.q;
end

if GAMS.method >= 3
  DAE.y(Bus.a) = a;
  DAE.y(Bus.v) = V;
  Line = gcall(Line);
  Qg = Qg(iBQg);
end

if GAMS.method == 1
  ro = MCP*getones(Bus);
end
if GAMS.method == 2
  [rows,cols] = size(MCP);
  if rows == 1,
    ro = MCP';
  else
    ro = MCP;
  end
end

Qgmin = Qgmin(iBQg);
Qgmax = Qgmax(iBQg);
if GAMS.basepl
  PG = full((sparse(iBPs,1,Ps,Bus.n,1)+Bus.Pg)*MVA);
  PL = full((sparse(iBPd,1,Pd,Bus.n,1)+Bus.Pl)*MVA);
else
  PG = full(sparse(iBPs,1,Ps,Bus.n,1)*MVA);
  PL = full(sparse(iBPd,1,Pd,Bus.n,1)*MVA);
end
QG = full(sparse(iBQg,1,Qg,Bus.n,1)*MVA);
QL = full((sparse(iBPd,1,Pd.*tanphi(Demand),Bus.n,1)+Bus.Ql)*MVA);
PayS = -ro(Bus.a).*PG;
PayD = ro(Bus.a).*PL;
ISOPay = -sum(ro(Bus.a).*Line.p*MVA);

if (Settings.showlf || GAMS.show) && clpsat.showopf

  fm_disp
  fm_disp(' Power Supplies')
  fm_disp(' ---------------------------------------------------------------')
  [Psmax,Psmin] = plim(Supply);
  if GAMS.method == 7
    fm_disp({'Bus','Ps','Ps max','Ps min','dPs_up','dPs_dw'})
    fm_disp({'<i>','[MW]','[MW]','[MW]','[MW]','[MW]'})
    fm_disp([getidx(Bus,Supply.bus),Ps*MVA,Psmax*MVA,Psmin*MVA,dPSup*MVA,dPSdw*MVA])
  else
    fm_disp({'Bus','Ps','Ps max','Ps min'})
    fm_disp({'<i>','[MW]','[MW]','[MW]'})
    fm_disp([getidx(Bus,Supply.bus),Ps*MVA,Psmax*MVA,Psmin*MVA])
  end
  fm_disp
  fm_disp(' Power Demands')
  fm_disp(' ---------------------------------------------------------------')
  [Pdmax,Pdmin] = plim(Demand);
  if GAMS.method == 7
    fm_disp({'Bus','Pd','Pd max','Pd min','dPd_up','dPd_dw'})
    fm_disp({'<i>','[MW]','[MW]','[MW]'})
    fm_disp([getidx(Bus,Demand.bus),Pd*MVA,Pdmax*MVA,Pdmin*MVA,dPDup*MVA,dPDdw*MVA])
  else
    fm_disp({'Bus','Pd','Pd max','Pd min'})
    fm_disp({'<i>','[MW]','[MW]','[MW]'})
    fm_disp([getidx(Bus,Demand.bus),Pd*MVA,Pdmax*MVA,Pdmin*MVA])
  end
  fm_disp
  fm_disp(' Generator Reactive Powers')
  fm_disp(' ---------------------------------------------------------------')
  if GAMS.method == 4 || GAMS.method == 6
    fm_disp({'Bus','Qg','Qgc','Qg max','Qg min'})
    fm_disp({'<i>','[MVar]','[MVar]','[MVar]','[MVar]'})
    fm_disp([getidx(Bus,iBQg),Qg*MVA,Qgc(iBQg)*MVA,Qgmax*MVA,Qgmin*MVA])
  else
    fm_disp({'Bus','Qg','Qg max','Qg min'})
    fm_disp({'<i>','[MVar]','[MVar]','[MVar]'})
    fm_disp([getidx(Bus,iBQg),Qg*MVA,Qgmax*MVA,Qgmin*MVA])
  end
  fm_disp
  fm_disp(' Power Flow Solution')
  fm_disp([' ----------------------------------------------------' ...
           '-----------'])
  fm_disp({'Bus','V','theta','PG','PL','QG','QL'})
  fm_disp({'<i>','[p.u.]','[rad]','[MW]','[MW]','[MVar]','[MVar]'})
  fm_disp([getidx(Bus,0),DAE.y(Bus.v),DAE.y(Bus.a),PG,PL,QG,QL])

  fm_disp
  fm_disp(' Prices and Pays')
  fm_disp([' ----------------------------------------------------' ...
           '-----------'])
  if GAMS.method == 3 || GAMS.method == 4 || GAMS.method == 6
    fm_disp({'Bus','LMP','NCP','Pay S','Pay D'})
    fm_disp({'<i>','[$/MWh]','[$/MWh]','[$/h]','[$/h]'})
    fm_disp([getidx(Bus,0),ro(Bus.a), NCP, PayS, PayD])
  else
    fm_disp({'Bus','LMP','Pay S','Pay D'})
    fm_disp({'<i>','[$/MWh]','[$/h]','[$/h]'})
    fm_disp([getidx(Bus,0),ro(Bus.a), PayS, PayD])
  end
  if GAMS.method == 4 || GAMS.method == 6
    fm_disp
    fm_disp(' "Critical" Power Flow Solution')
    fm_disp(' ---------------------------------------------------------------')
    fm_disp({'Bus','Vc','thetac','PGc','PLc','QGc','QLc'})
    fm_disp({'<i>','[p.u.]','[rad]','[MW]','[MW]','[MVar]', ...
             '[MVar]'})
    PG = (1+lambdac+kg)*PG;
    PL = (1+lambdac)*PL;
    QL = (1+lambdac)*QL;
    fm_disp([getidx(Bus,0),Vc,ac,PG,PL,Qgc*MVA,QL])
  end
  fm_disp
  if GAMS.flow
    fm_disp(' Flows on Transmission Lines')
    fm_disp(' ---------------------------------------------------------------')
    switch GAMS.flow
     case 1,
      fm_disp({'From Bus','To Bus','Iij','Iijmax', ...
               'Iij margin','Iji','Ijimax','Iji margin'},1)
     case 2,
      fm_disp({'From Bus','To Bus','Pij','Pijmax', ...
               'Pij margin','Pji','Pjimax','Pji margin'},1)
     case 3,
      fm_disp({'From Bus','To Bus','Sij','Sijmax', ...
               'Sij margin','Sji','Sjimax','Sji margin'},1)
    end
    fm_disp({'<i>','<j>','[p.u.]','[p.u.]', ...
	     '[p.u.]','[p.u.]','[p.u.]','[p.u.]'})
    fm_disp([Line.fr, Line.to,Pij, ...
             L.val(:,5),abs((-abs(Pij)+L.val(:,5))), ...
             Pji,L.val(:,5),abs((-abs(Pji)+L.val(:,5)))])
    fm_disp
  else
    fm_disp('Flow limits are disabled.')
  end
  if GAMS.method == 4 || GAMS.method == 6
    fm_disp(' Flows on Transmission Lines of the "Critical" System')
    fm_disp(' ---------------------------------------------------------------')
    switch GAMS.flow
     case 1,
      fm_disp({'From Bus','To Bus','Iijc','Iijcmax', ...
               'Iijc margin','Ijic','Ijicmax','Ijic margin'})
     case 2,
      fm_disp({'From Bus','To Bus','Pijc','Pijcmax', ...
               'Pijc margin','Pjic','Pjicmax','Pjic margin'})
     case 3,
      fm_disp({'From Bus','To Bus','Sijc','Sijcmax', ...
               'Sijc margin','Sjic','Sjicmax',['Sjic margin']})
    end
    fm_disp({'<i>','<j>','[p.u.]','[p.u.]', ...
	     '[p.u.]','[p.u.]','[p.u.]','[p.u.]'})
    if GAMS.flow
      fm_disp([Line.fr, Line.to,Pijc, ...
               L.val(:,5),abs((-abs(Pijc)+L.val(:,5))), ...
               Pjic,L.val(:,5),abs((-abs(Pjic)+L.val(:,5)))])
      fm_disp
    end
  end

  fm_disp
  fm_disp(' Totals')
  fm_disp(' ---------------------------------------------------------------')
  if GAMS.method >= 4,
    fm_disp([' omega = ',num2str(omega(1))])
    fm_disp([' lambda_c = ',num2str(lambdac),' [p.u.]'])
    fm_disp([' kg = ',num2str(kg),' [p.u.]'])
  end
  if GAMS.method == 1
    fm_disp([' Market Clearing Price = ',num2str(MCP),' [$/MWh]'])
  end

  total_loss = 1e-5*round(sum(Line.p)*1e5)*MVA;
  bid_loss = 1e-5*round((sum(Line.p)-Snapshot(1).Ploss)*1e5)*MVA;

  fm_disp([' Total Losses = ',num2str(total_loss),' [MW]'])
  fm_disp([' Bid Losses = ',num2str(bid_loss),' [MW]'])
  fm_disp([' Total demand = ',num2str(sum(Pd)*MVA),' [MW]'])
  fm_disp([' Total Transaction Level = ', ...
           fvar(sum(Pd)*MVA+TPQ,8),' [MW]']);
  if GAMS.method == 4 || GAMS.method == 6
    fm_disp([' Maximum Loading Condition = ', ...
             fvar((1+lambdac)*(sum(Pd)*MVA+TPQ),8),' [MW]']);
    fm_disp([' Available Loading Capability = ', ...
             fvar(lambdac*(sum(Pd)*MVA+TPQ),8),' [MW]']);
  end
  if GAMS.method == 5
    fm_disp([' Maximum Loading Condition = ', ...
             fvar(lambdac*(sum(Pd)*MVA+TPQ),8),' [MW]']);
  end
  fm_disp([' IMO Pay = ',num2str(ISOPay),' [$/h]']);
  fm_disp

end
fm_disp(' ---------------------------------------------------------------')
fm_disp([' Check file ',Path.psat,'fm_gams.lst for GAMS report.'])
gams_mstat(modelstat)
gams_sstat(solvestat)
if strcmp(control,'6')
  fm_disp([' PSAT-GAMS Optimization Routine completed in ', ...
           num2str(etime(clock,initial_time)),' s'])
else
  fm_disp([' PSAT-GAMS Optimization Routine completed in ',num2str(toc),' s'])
end

if noDem, Demand = restore(Demand); end

if ~GAMS.basepl
  Bus.Pl = buspl;
  Bus.Ql = busql;
  PQ = pqreset(PQ,'all');
end
if ~GAMS.basepg
  Snapshot(1).Ploss = ploss;
  Bus.Pg = buspg;
  Bus.Qg = busqg;
  PV = pvreset(PV,'all');
end

% restore original bus power injections
Bus.Pg = Snapshot(1).Pg;
Bus.Qg = Snapshot(1).Qg;
Bus.Pl = Snapshot(1).Pl;
Bus.Ql = Snapshot(1).Ql;

% ===============================================================
function [Pij,Pji,Qg] = updatePF(Pd,Ps,iBQg)
% Power FLow Solution with the current simple auction solution
% ===============================================================

global Settings Bus Line PQ PV SW Demand Supply GAMS

Busold = Bus;
Demand = pset(Demand,Pd);
Supply = pset(Supply,Ps);

pg = SW.pg;
pqsum(Demand,1);
pgsum(Supply,1);

show_old = Settings.show;
Settings.show = 0;
Settings.locksnap = 1;
fm_spf
Settings.locksnap = 0;
Settings.show = show_old;
[Pij,Pji] = flows(Line,max(GAMS.flow,1));
Qg = Bus.Qg(iBQg);
Bus = Busold;
SW = setpg(SW,'all',pg);
PQ = restore(PQ);
PV = pvreset(PV,'all');

% ==========================================================================
function NCP = compNCP(V,a,mV,mFij,mFji)
% Nodal Congestion Prices
% ==========================================================================

global DAE SW GAMS Line Bus

yold = DAE.y;
Gyold = DAE.Gy;

DAE.y(Bus.a) = a;
DAE.y(Bus.v) = V;
Gycall(Line)
fm_setgy(SW.refbus)
[Fij,Jij,Fji,Jji] = fjh2(Line,max(GAMS.flow,1));
dH_dtV = Jij'*mFij + Jji'*mFji + [getzeros(Bus);mV];
dH_dtV(SW.refbus,:) = 0;
NCP = DAE.Gy'\dH_dtV;
NCP = NCP(Bus.a);

DAE.y = yold;
DAE.Gy = Gyold;

% ==========================================================================
function varargout = psatgams(varargin)
% PSAT-GAMS interface
% ==========================================================================

global Settings Path

% writing GAMS input data
%---------------------------------------------------------------------
fid1 = fopen('psatglobs.gms','wt+');
fid2 = fopen('psatdata.gms','wt+');
fprintf(fid2,'%s\n','$onempty');

for i = 2:nargin
  if ischar(varargin{i})
    fprintf(fid1,'$setglobal %s ''%s''\n',inputname(i), ...
            varargin{i});
  elseif isnumeric(varargin{i})
    fprintf(fid2,'$kill %s\n',inputname(i));
    if length(varargin{i}) == 1
      fprintf(fid2,'scalar %s /%f/;\n',inputname(i),varargin{i});
    else
      fprintf(fid2,'parameter %s /\n',inputname(i));
      [x,y,v] = find(varargin{i});
      fprintf(fid2,'%d.%d %f\n',[x y v]');
      fprintf(fid2,'/;\n');
    end
  elseif isstruct(varargin{i})
    labels = varargin{i}.labels;
    fprintf(fid2,'$kill %s\n',varargin{i}.name);
    fprintf(fid2,'parameter %s /\n',varargin{i}.name);
    [x,y,v] = find(varargin{i}.val);
    if iscell(labels{1})
      %a = fm_strjoin(labels{1}(x),'.',labels{2}(y)',[blanks(length(x))',num2str(v)]);
      %fprintf(fid2,'%s\n',a{:});
      for j = 1:length(x)
	fprintf(fid2,'%s.%s %f\n',labels{1}{x(j)},labels{2}{y(j)},v(j));
      end
    else
      for j = 1:length(x)
	fprintf(fid2,'%s %f\n',labels{y(j)},v(j));
      end
    end
    fprintf(fid2,'/;\n');
  end
end
fprintf(fid2,'%s\n','$offempty');
fclose(fid1);
fclose(fid2);

% Lauching GAMS
%---------------------------------------------------------------------
status = 0;
t0 = clock;
%disp(['gams ',varargin{1},' -error=PSAT'])
[status,result] = system(['gams ',varargin{1}]);
fm_disp([' GAMS routine completed in ',num2str(etime(clock,t0)),' s'])
if status
  fm_disp(result)
  return
end

% Reading GAMS output
%---------------------------------------------------------------------
nout = 0;
EPS = eps;
clear psatsol
psatsol
if nout < nargout
  for i = nout+1:nargout
    varargout{i} = [];
  end
end

if nout > nargout
  varargout(nargout+1:nout) = [];
end

%---------------------------------------------------------------------
function gams_mstat(status)

if isempty(status), return, end

switch status
 case 0, fm_disp(' GAMS model status: not available')
 case 1, fm_disp(' GAMS model status: optimal')
 case 2, fm_disp(' GAMS model status: locally optimal')
 case 3, fm_disp(' GAMS model status: unbounded')
 case 4, fm_disp(' GAMS model status: infeasible')
 case 5, fm_disp(' GAMS model status: locally infeasible')
 case 6, fm_disp(' GAMS model status: intermediate infeasible')
 case 7, fm_disp(' GAMS model status: intermediate non-optimal')
 case 8, fm_disp(' GAMS model status: integer solution')
 case 9, fm_disp(' GAMS model status: intermediate non-integer')
 case 10, fm_disp(' GAMS model status: integer infeasible')
 case 11, fm_disp(' GAMS model status: ???')
 case 12, fm_disp(' GAMS model status: error unknown')
 case 13, fm_disp(' GAMS model status: error no solution')
 otherwise, fm_disp(' GAMS model status: unknown model status')
end

%---------------------------------------------------------------------
function gams_sstat(status)

if isempty(status), return, end

switch status
 case 0, fm_disp(' GAMS solver status: not available')
 case 1, fm_disp(' GAMS solver status: normal completion')
 case 2, fm_disp(' GAMS solver status: iteration interrupt')
 case 3, fm_disp(' GAMS solver status: resource interrupt')
 case 4, fm_disp(' GAMS solver status: terminated by solver')
 case 5, fm_disp(' GAMS solver status: evaluation error limit')
 case 6, fm_disp(' GAMS solver status: unknown')
 case 7, fm_disp(' GAMS solver status: ???')
 case 8, fm_disp(' GAMS solver status: error preprocessor error')
 case 9, fm_disp(' GAMS solver status: error setup failure')
 case 10, fm_disp(' GAMS solver status: error solver failure')
 case 11, fm_disp(' GAMS solver status: error internal solver error')
 case 12, fm_disp(' GAMS solver status: error post-processor error')
 case 13, fm_disp(' GAMS solver status: error system failure')
 otherwise, fm_disp(' GAMS solver status: unknown solver status')
end