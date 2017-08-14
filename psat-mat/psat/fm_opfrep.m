function fm_opfrep
%FM_OPFREP writes OPF report file
%
%see also FM_OPFM FM_OPFSD and OPF structure for settings.
%
%Author:    Federico Milano
%Date:      09-Mar-2005
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global OPF DAE Bus Varname Settings File Path
global Line SW PV PQ Demand Supply Rsrv Snapshot

if OPF.init == 0
  fm_disp('Solve OPF before writing the OPF report.',2)
end

if OPF.init > 2
  fm_disp('OPF report is not defined for the current OPF solution.',2)
end

% some useful data and indexes
MVA = Settings.mva;

[Psmax,Psmin] = plim(Supply);
[Pdmax,Pdmin] = plim(Demand);
[Prmax,Prmin] = plim(Rsrv);

nDemand = max(1,Demand.n);
busG = [SW.bus; PV.bus];
[busS,idxS] = setdiff(busG,Supply.bus);
n_gen = Supply.n+length(busS);
busG = [Supply.bus;busS];

nS = 1:Supply.n;
nD = 1:nDemand;
nG = 1:n_gen;
nB = Bus.a';
nL = 1:Line.n;
nR = 1:Rsrv.n;

if OPF.envolt
  [Vmax,Vmin] = fm_vlim(OPF.vmax,OPF.vmin);
else
  Vmin = OPF.vmin*getones(Bus);
  Vmax = OPF.vmax*getones(Bus);
end

if OPF.enflow
  Iijmax = getflowmax(Line,OPF.flow);
else
  Iijmax = 999*ones(Line.n,1);
end

if OPF.enreac
  [Qgmax,Qgmin] = fm_qlim('gen');
else
  Qgmin = -99*MVA*ones(n_gen,1);
  Qgmax =  99*MVA*ones(n_gen,1);
end

n1 = Bus.n;
n2 = 2*n1;
n3 = 3*n1;
n4 = 4*n1;
n5 = 5*n1;
n6 = 6*n1;
n7 = 7*n1;

% numbering
if OPF.init == 1

  n_s = 2*Supply.n+2*nDemand+2*n_gen+n2+2*Line.n+2*Rsrv.n;
  if Rsrv.n, n_s = n_s + 1; end

  mu_Psmin  = OPF.guess(n_s+nS);       idx = Supply.n;
  mu_Psmax  = OPF.guess(n_s+idx+nS);   idx = idx + Supply.n;
  mu_Pdmin  = OPF.guess(n_s+idx+nD);   idx = idx + nDemand;
  mu_Pdmax  = OPF.guess(n_s+idx+nD);   idx = idx + nDemand;
  mu_Qgmin  = OPF.guess(n_s+idx+nG);   idx = idx + n_gen;
  mu_Qgmax  = OPF.guess(n_s+idx+nG);   idx = idx + n_gen;
  mu_Vmin   = OPF.guess(n_s+idx+nB);   idx = idx + n1;
  mu_Vmax   = OPF.guess(n_s+idx+nB);   idx = idx + n1;
  mu_Iijmax = 2*Iijmax.*OPF.guess(n_s+idx+nL);   idx = idx + Line.n;
  mu_Ijimax = 2*Iijmax.*OPF.guess(n_s+idx+nL);   idx = idx + Line.n;
  if Rsrv.n
    mu_Prmin  = OPF.guess(n_s+idx+nR); idx = idx + Rsrv.n;
    mu_Prmax  = OPF.guess(n_s+idx+nR); idx = idx + Rsrv.n;
    mu_sumPrd = OPF.guess(n_s+idx+1);
  end

  a = OPF.guess(2*n_s+nB);
  V = OPF.guess(2*n_s+n1+nB);
  Qg = OPF.guess(2*n_s+n2+nG);
  Ps = OPF.guess(2*n_s+n2+n_gen+nS);
  Pd = OPF.guess(2*n_s+n2+n_gen+Supply.n+nD);
  if Rsrv.n
    Pr = OPF.guess(2*n_s+n2+n_gen+Supply.n+nDemand+nR);
  end
  rhop = OPF.guess(2*n_s+n2+n_gen+Supply.n+nDemand+Rsrv.n+nB);
  rhoq = OPF.guess(2*n_s+n3+n_gen+Supply.n+nDemand+Rsrv.n+nB);

elseif OPF.init == 2

  n_s = 2*Supply.n+2*nDemand+4*n_gen+n4+2+4*Line.n+2*Rsrv.n;
  if Rsrv.n, n_s = n_s + 1; end

  mu_Psmin  = OPF.guess(n_s+nS);       idx = Supply.n;
  mu_Psmax  = OPF.guess(n_s+idx+nS);   idx = idx + Supply.n;
  mu_Pdmin  = OPF.guess(n_s+idx+nD);   idx = idx + nDemand;
  mu_Pdmax  = OPF.guess(n_s+idx+nD);   idx = idx + nDemand;
  mu_Qgmin  = OPF.guess(n_s+idx+nG);   idx = idx + n_gen;
  mu_Qgmax  = OPF.guess(n_s+idx+nG);   idx = idx + n_gen;
  mu_Vmin   = OPF.guess(n_s+idx+nB);   idx = idx + n1;
  mu_Vmax   = OPF.guess(n_s+idx+nB);   idx = idx + n1;
  mu_Qgcmin = OPF.guess(n_s+idx+nG);   idx = idx + n_gen;
  mu_Qgcmax = OPF.guess(n_s+idx+nG);   idx = idx + n_gen;
  mu_Vcmin  = OPF.guess(n_s+idx+nB);   idx = idx + n1;
  mu_Vcmax  = OPF.guess(n_s+idx+nB);   idx = idx + n1;
  mu_lcmin  = OPF.guess(n_s+idx+1);    idx = idx + 1;
  mu_lcmax  = OPF.guess(n_s+idx+1);    idx = idx + 1;
  mu_Iijmax = OPF.guess(n_s+idx+nL);   idx = idx + Line.n;
  mu_Iijcmax= OPF.guess(n_s+idx+nL);   idx = idx + Line.n;
  mu_Ijimax = OPF.guess(n_s+idx+nL);   idx = idx + Line.n;
  mu_Ijicmax= OPF.guess(n_s+idx+nL);   idx = idx + Line.n;
  if Rsrv.n
    mu_Prmin  = OPF.guess(n_s+idx+nR); idx = idx + Rsrv.n;
    mu_Prmax  = OPF.guess(n_s+idx+nR); idx = idx + Rsrv.n;
    mu_sumPrd = OPF.guess(n_s+idx+1);
  end

  a = OPF.guess(2*n_s+nB);
  V = OPF.guess(2*n_s+n1+nB);
  Qg = OPF.guess(2*n_s+n2+nG);
  Ps = OPF.guess(2*n_s+n2+n_gen+nS);
  Pd = OPF.guess(2*n_s+n2+n_gen+Supply.n+nD);
  ac = OPF.guess(2*n_s+n2+n_gen+Supply.n+nDemand+nB);
  Vc = OPF.guess(2*n_s+n3+n_gen+Supply.n+nDemand+nB);
  kg = OPF.guess(2*n_s+n4+n_gen+Supply.n+nDemand+1);
  Qgc = OPF.guess(2*n_s+n4+n_gen+Supply.n+nDemand+1+nG);
  lambda = OPF.guess(2*n_s+n4+n_gen+Supply.n+nDemand+2+n_gen);
  if Rsrv.n
    Pr = OPF.guess(2*n_s+n4+2*n_gen+Supply.n+nDemand+2+nR);
  end
  rhop = OPF.guess(2*n_s+n4+2*n_gen+Supply.n+nDemand+2+Rsrv.n+nB);
  rhoq = OPF.guess(2*n_s+n5+2*n_gen+Supply.n+nDemand+2+Rsrv.n+nB);
  rhopc = OPF.guess(2*n_s+n6+2*n_gen+Supply.n+nDemand+2+Rsrv.n+nB);
  rhoqc = OPF.guess(2*n_s+n7+2*n_gen+Supply.n+nDemand+2+Rsrv.n+nB);

end

Pay = rhop.*Line.p*MVA;
ISOPay = sum(Pay);
[Iij,Iji] = flows(Line,OPF.flow);

if OPF.init == 2
  yold = DAE.y;
  DAE.y = [ac;Vc];
  if OPF.line
    status = Line.u(OPF.line);
    Line = setstatus(Line,OPF.line,0);
  end
  [Iijc,Ijic] = flows(Line,OPF.flow);
  if OPF.line
    Line = setstatus(Line,OPF.line,status);
  end
  DAE.y = yold;
end

% initialize report structures
Header{1,1}{1,1} = 'OPTIMAL POWER FLOW REPORT';
switch OPF.init
 case 1, Header{1,1}{2,1} = '(Standard OPF)';
 case 2, Header{1,1}{2,1} = '(Multiobjective OPF)';
 otherwise, % nothing to do ...
end
Header{1,1}{3,1} = ' ';
Header{1,1}{4,1} = ['P S A T  ',Settings.version];
Header{1,1}{5,1} = ' ';
Header{1,1}{6,1} = 'Author:  Federico Milano, (c) 2002-2016';
Header{1,1}{7,1} = 'e-mail:  federico.milano@ucd.ie';
Header{1,1}{8,1} = 'website: faraday1.ucd.ie/psat.html';
Header{1,1}{9,1} = ' ';
Header{1,1}{10,1} = ['File:  ', Path.data,strrep(File.data,'(mdl)','.mdl')];
Header{1,1}{11,1} = ['Date:  ',datestr(now,0)];

Matrix{1,1} = [];
Cols{1,1} = '';
Rows{1,1} = '';

Header{2,1} = 'NETWORK STATISTICS';
Matrix{2,1} = n1;
Rows{2,1} = {'Buses:'};
Cols{2,1} = '';

ntraf = transfno(Line);
nline = Line.n-ntraf;

if nline > 0
  Matrix{2,1}(2,1) = nline;
  Rows{2,1}{2,1} = 'Lines:';
  idx = 2;
else
  idx = 1;
end
if ntraf > 0
  idx = idx + 1;
  Matrix{2,1}(idx,1) = ntraf;
  Rows{2,1}{idx,1} = 'Transformers:';
end
Matrix{2,1}(idx+1,1) = SW.n+PV.n;
Rows{2,1}{idx+1,1} = 'Generators:';
Matrix{2,1}(idx+2,1) = PQ.n;
Rows{2,1}{idx+2,1} = 'Loads:';
Matrix{2,1}(idx+3,1) = Supply.n;
Rows{2,1}{idx+3,1} = 'Supplies:';
Matrix{2,1}(idx+4,1) = Demand.n;
Rows{2,1}{idx+4,1} = 'Demands:';

% statistics of the current solution algorithm
Header{3,1} = 'SOLUTION STATISTICS';
Cols{3,1} = '';
bindings = length(find(round(OPF.guess(n_s+1:2*n_s)*1e5)));
Rows{3,1} = {'Objective Function [$/h]:'; ...
             'Active Limits:'; ...
             'Number of Iterations:'; ...
	     'Barrier Parameter:'; ...
	     'Variable Mismatch:';
             'Power Flow Equation Mismatch:';
             'Objective Function Mismatch:'};
Matrix{3,1} = [OPF.obj*MVA;bindings;OPF.iter;...
               OPF.ms;OPF.dy;OPF.dF;OPF.dG];
if OPF.init == 2
  Rows{3,1}{1,1} = 'Objective Function:';
  Rows{3,1}{7,1} = 'Weighting Factor:';
  Matrix{3,1}(7,1) = OPF.w;
end

% Power Supplies
Header{4,1} = 'POWER SUPPLIES';
Cols{4,1} = {'Bus','mu min','Ps min','Ps','Ps max','mu max'; ...
             ' ',' ','[MW]','[MW]','[MW]',' '};
for kkk = 1:Supply.n
  Rows{4,1}{kkk,1} = Bus.names{Supply.bus(kkk)};
end
Matrix{4,1} = [mu_Psmin,Psmin*MVA,Ps*MVA,Psmax*MVA,mu_Psmax];
idx = 5;

% Power Demands
if Demand.n
  Header{idx,1} = 'POWER DEMANDS';
  Cols{idx,1} = {'Bus','mu min','Pd min','Pd','Pd max','mu max'; ...
               ' ',' ','[MW]','[MW]','[MW]',' '};
  for kkk = 1:Demand.n
    Rows{idx,1}{kkk,1} = Bus.names{Demand.bus(kkk)};
  end
  Matrix{idx,1} = [mu_Pdmin,Pdmin*MVA,Pd*MVA,Pdmax*MVA,mu_Pdmax];
  idx = idx+1;
end

% Reactive Powers
Header{idx,1} = 'REACTIVE POWERS';
Cols{idx,1} = {'Bus','mu min','Qg min','Qg','Qg max','mu max'; ...
               ' ',' ','[MVar]','[MVar]','[MVar]',' '};
for kkk = 1:n_gen
  Rows{idx,1}{kkk,1} = Bus.names{busG(kkk)};
end
Matrix{idx,1} = [mu_Qgmin,Qgmin*MVA,Qg*MVA,Qgmax*MVA,mu_Qgmax];
idx = idx+1;

if OPF.init == 2
  Header{idx,1} = 'CRITICAL REACTIVE POWERS';
  Cols{idx,1} = {'Bus','mu min','Qgc min','Qgc','Qgc max','mu max'; ...
                 ' ',' ','[MVar]','[MVar]','[MVar]',' '};
  for kkk = 1:n_gen
    Rows{idx,1}{kkk,1} = Bus.names{busG(kkk)};
  end
  Matrix{idx,1} = [mu_Qgcmin,Qgmin*MVA,Qgc*MVA,Qgmax*MVA,mu_Qgcmax];
  idx = idx+1;
end

% Power Reserves
if Rsrv.n

  Header{idx,1} = 'POWER RESERVES';
  Cols{idx,1} = {'Bus','mu min','Pr min','Pr','Pr max','mu max'; ...
               ' ',' ','[MW]','[MW]','[MW]',' '};
  for kkk = 1:Rsrv.n
    Rows{idx,1}{kkk,1} = Bus.names{Rsrv.bus(kkk)};
  end
  Matrix{idx,1} = [mu_Prmin,Prmin*MVA,Pr*MVA,Prmax*MVA,mu_Prmax];
  idx = idx+1;

  Header{idx,1} = 'POWER RESERVE BALANCE';
  Cols{idx,1} = {' ','Sum Pr','Sum Pd','mu'; ...
                 ' ','[MW]','[MW]',' '};
  Rows{idx,1} = {' '};
  Matrix{idx,1} = [sum(Pr)*MVA,sum(Pd)*MVA,mu_sumPrd];
  idx = idx+1;

end

if OPF.init == 2
  Header{idx,1} = 'LAMBDA';
  Cols{idx,1} = {' ','mu min','lambda min','lambda','lambda max','mu max'};
  Rows{idx,1} = {' '};
  Matrix{idx,1} = [mu_lcmin, OPF.lmin, lambda, OPF.lmax, mu_lcmin];
  idx = idx+1;
end

switch OPF.flow
 case 1, I = 'I';
 case 2, I = 'P';
 case 3, I = 'S';
end

% Voltages
Header{idx,1} = 'VOLTAGES';
Cols{idx,1} = {'Bus','mu min','V min','V','V max','mu max',...
               'phase';' ',' ','[p.u.]','[p.u.]','[p.u.]',' ',...
               '[rad]'};
Rows{idx,1} = Bus.names;
Matrix{idx,1} = [mu_Vmin,Vmin,V,Vmax,mu_Vmax,a];
idx = idx+1;

if OPF.init == 2
  Header{idx,1} = 'CRITICAL VOLTAGES';
  Cols{idx,1} = {'Bus','mu min','Vc min','Vc','Vc max','mu max',...
                 'phase';' ',' ','[p.u.]','[p.u.]','[p.u.]',' ',...
                 '[rad]'};
  Rows{idx,1} = Bus.names;
  Matrix{idx,1} = [mu_Vcmin,Vmin,Vc,Vmax,mu_Vcmax,ac];
  idx = idx+1;
end

% Power flow
Header{idx,1} = 'POWER FLOW';
Cols{idx,1} = {'Bus','P','Q','rho P','rho Q','NCP','Pay'; ...
               ' ','[MW]','[MVar]','[$/MWh]','[$/MVArh]',...
               '[$/MWh]','[$/h]'};
Rows{idx,1} = Bus.names;
Matrix{idx,1} = [Line.p*MVA,Line.q*MVA,-rhop,...
                 -rhoq,OPF.NCP(Bus.a),round(Pay)];
idx = idx+1;

if OPF.init == 2
  Header{idx,1} = 'CRITICAL POWER FLOW';
  Cols{idx,1} = {'Bus','Pc','Qc','rho Pc','rho Qc'; ...
                 ' ','[MW]','[MVar]',' ',' '};
  Rows{idx,1} = Bus.names;
  Matrix{idx,1} = [OPF.gpc*MVA,OPF.gqc*MVA,-rhopc,-rhoqc];
  idx = idx+1;
end

% Flows in transmission lines

if OPF.init == 1

  Header{idx,1} = 'FLOWS IN TRANSMISSION LINES';
  Cols{idx,1} = {'From bus','To bus',[I,'_ij'],[I,'_ji'], ...
                 [I,'_ij max'],['mu ',I,'_ij'],['mu ',I,'_ji']; ...
                 ' ',' ','[p.u.]','[p.u.]','[p.u.]',' ',' '};
  for kkk = 1:Line.n
    Rows{idx,1}{kkk,1} = Bus.names{Line.fr(kkk)};
    Rows{idx,1}{kkk,2} = Bus.names{Line.to(kkk)};
  end
  Matrix{idx,1} = [Iij,Iji,Iijmax,mu_Iijmax,mu_Ijimax];
  idx = idx+1;

elseif OPF.init == 2

  Header{idx,1} = 'FLOWS IN TRANSMISSION LINES';
  Cols{idx,1} = {'From bus','To bus',[I,'_ij'],[I,'_ij c'],[I,'_ij max'], ...
                 ['mu ',I,'_ij'],['mu ',I,'_ij c']; ...
                 ' ',' ','[p.u.]','[p.u.]','[p.u.]',' ',' '};
  for kkk = 1:Line.n
    Rows{idx,1}{kkk,1} = Bus.names{Line.fr(kkk)};
    Rows{idx,1}{kkk,2} = Bus.names{Line.to(kkk)};
  end
  Matrix{idx,1} = [Iij,Iijc,Iijmax,mu_Iijmax,mu_Iijcmax];
  idx = idx+1;

  Header{idx,1} = 'FLOWS IN TRANSMISSION LINES';
  Cols{idx,1} = {'From bus','To bus',[I,'_ji'],[I,'_ji c'],[I,'_ji max'], ...
                 ['mu ',I,'_ji'],['mu ',I,'_ji c']; ...
                 ' ',' ','[p.u.]','[p.u.]','[p.u.]',' ',' '};
  for kkk = 1:Line.n
    Rows{idx,1}{kkk,1} = Bus.names{Line.to(kkk)};
    Rows{idx,1}{kkk,2} = Bus.names{Line.fr(kkk)};
  end
  Matrix{idx,1} = [Iji,Ijic,Iijmax,mu_Ijimax,mu_Ijicmax];
  idx = idx+1;

end

% Totals
Header{idx,1} = 'TOTALS';
Cols{idx,1} = '';
Rows{idx,1} = {'TOTAL LOSSES [MW]:';'BID LOSSES [MW]';...
               'TOTAL DEMAND [MW]:'; ...
               'TOTAL TRANSACTION LEVEL [MW]:';'IMO PAY [$/h]:'};

tot_loss = 1e-5*round((sum(Line.p))*1e5)*MVA;
if OPF.basepg
  length(Snapshot.y);
  ploss = Snapshot(1).Ploss;
else
  ploss = 0;
end
bid_loss = 1e-5*round((sum(Line.p)-ploss)*1e5)*MVA;
tot_demd = sum(Pd)*MVA;
tot_pq = totp(PQ)*MVA;
ttl = tot_demd+OPF.basepl*tot_pq;

Matrix{idx,1} = [tot_loss; bid_loss;...
                 tot_demd;ttl;ISOPay];
idx = idx + 1;

if OPF.init == 2
  Header{idx,1} = 'MAXIMUM LOADING CONDITION';
  Cols{idx,1} = '';
  Rows{idx,1} = {'LAMBDA:';'DISTRIBUTED LOSSES KG:';...
                 'MAXIMUM LOADING COND. [MW]:'; ...
                 'AVAILABLE LOADING COND. [MW]:'};
  if ~Demand.n
    MLC = (1+lambda)*tot_demd;
    ALC = lambda*tot_demd;
  else
    MLC = (1+lambda)*(tot_demd+tot_pq);
    ALC = lambda*(tot_demd+tot_pq);
  end
  Matrix{idx,1} = [lambda; kg; MLC; ALC];
end

% writing data...
fm_write(Matrix,Header,Cols,Rows)