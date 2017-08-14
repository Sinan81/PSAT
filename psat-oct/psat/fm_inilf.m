function fm_inilf
% FM_INILF initialize all system and component variables
%          for power flow computations
%
% FM_INILF
%
%see also FM_SLF
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    22-Feb-2003
%Update:    09-Jul-2003
%Version:   1.0.2
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global DAE Settings OPF LIB SNB Varname Varout SSSA PMU clpsat Snapshot
global Bus Areas Regions Shunt SW PV PQ PQgen Line Lines Twt Fl Mn
global Demand Supply Pl Syn Mass Exc Fault Breaker Ind Thload Tg COI
global Ltc Tap Oxl Pss Mass SSR Svc Statcom Tcsc Sssc Upfc Hvdc Pod
global Rmpg Rmpl Rsrv Vltn Ypdp Sofc Cac Cluster Exload Phs Wind Cswt
global Dfig Ddsg Busfreq Mixload Jimma Pmu WTFR Spv Spq

% Deleting Self-generated functions
clear fm_call

% General Variables
DAE.kg = 0;
DAE.lambda = 0;
Settings.iter = 0;
Settings.nseries = 0;
Settings.error = Settings.lftol+1;

% OPF, CPF, LIB & SNB variables
OPF.report = [];
OPF.init = 0;
OPF.line = 0;
CPF.init = 0;
LIB.lambda = 0;
LIB.dldp = [];
LIB.bus = [];
LIB.init = 0;
SNB.lambda = 0;
SNB.dldp = [];
SNB.bus = [];
SNB.init = 0;

% Variable Name Structure
Varname.uvars = '';
Varname.fvars = '';
Varname.nvars = 0;
Varname.idx = [];
Varname.pos = [];
Varname.areas = 0;
Varname.regions = 0;

% Output variables
Varout.t = [];
Varout.vars = [];
Varout.idx = [];
Varout.surf = 0;
Varout.movie = [];
Varout.xb = [];
Varout.yb = [];

% Snapshot
Snapshot = struct( ...
    'name','', ...
    'time',Settings.t0, ...
    'y',[], ...
    'x', [], ...
    'Ybus', [], ...
    'Pg', [], ...
    'Qg', [], ...
    'Pl', [], ...
    'Ql', [], ...
    'Gy', [], ...
    'Fx', [], ...
    'Fy', [], ...
    'Gx', [], ...
    'Ploss', [], ...
    'Qloss', [], ...
    'it', 0);

% Numbers
DAE.m = 0;
DAE.n = 0;
DAE.npf = 0;

% Time
DAE.t = -1;

% Vectors
DAE.x = [];
DAE.y = [];
DAE.g = [];
DAE.f = [];

% Jacobians
DAE.Gy = [];
DAE.Gx = [];
DAE.Gl = [];
DAE.Gk = [];
DAE.Fx = [];
DAE.Fy = [];
DAE.Fl = [];
DAE.Fk = [];

% small signal stability analysis parameters
SSSA.pf = [];
SSSA.eigs = [];
SSSA.report = [];

% Phasor Measurment Units
PMU.number = 0;
PMU.voltage = '';
PMU.angle = '';
PMU.location = '';
PMU.report = '';
PMU.measv = 0;
PMU.measc = 0;
PMU.pseudo = 0;
PMU.noobs = 0;

% initialize components
Bus = init_bus(Bus);
Areas = init_areas(Areas);
Regions = init_areas(Regions);
Shunt = init_shunt(Shunt);
SW = init_sw(SW);
PV = init_pv(PV);
PQ = init_pq(PQ);
PQgen = init_pq(PQgen);
Line = init_line(Line);
Lines = init_lines(Lines);
Twt = init_twt(Twt);
Fl = init_fl(Fl);
Demand = init_demand(Demand);
Supply = init_supply(Supply);
Mn = init_mn(Mn);
Pl = init_pl(Pl);
Syn = init_syn(Syn);
Mass = init_mass(Mass);
Exc = init_exc(Exc);
Fault = init_fault(Fault);
Breaker = init_breaker(Breaker);
Ind = init_ind(Ind);
Thload = init_thload(Thload);
Tg = init_tg(Tg);
COI = init_coi(COI);
Ltc = init_ltc(Ltc);
Tap = init_tap(Tap);
Oxl = init_oxl(Oxl);
Pss = init_pss(Pss);
Mass = init_mass(Mass);
SSR = init_ssr(SSR);

% FACTS
Svc = init_svc(Svc);
Statcom = init_statcom(Statcom);
Tcsc = init_tcsc(Tcsc);
Sssc = init_sssc(Sssc);
Upfc = init_upfc(Upfc);
Hvdc = init_hvdc(Hvdc);
Pod = init_pod(Pod);

% Market data
Rmpg = init_rmpg(Rmpg);
Rmpl = init_rmpl(Rmpl);
Rsrv = init_rsrv(Rsrv);
Vltn = init_vltn(Vltn);
Ypdp = init_ypdp(Ypdp);

% ----------------------------------------------------------- %
%                       W A R N I N G                         %
% ----------------------------------------------------------- %
% Following lines have been written by the UDM build utility. %
% This utility requires you do NOT change anything beyond     %
% this point in order to be able to correctly install and     %
% uninstall UDMs.                                             %
% ----------------------------------------------------------- %

Sofc = init_sofc(Sofc);

Cac = init_cac(Cac);
Cluster = init_cluster(Cluster);

Exload = init_exload(Exload);
Phs = init_phs(Phs);

Wind = init_wind(Wind);
Cswt = init_cswt(Cswt);
Dfig = init_dfig(Dfig);
Ddsg = init_ddsg(Ddsg);

Busfreq = init_busfreq(Busfreq);
Pmu = init_pmu(Pmu);
Mixload = init_mixload(Mixload);
Jimma = init_jimma(Jimma);
WTFR = init_wtfr(WTFR);
Spv = init_spv(Spv);
Spq = init_spq(Spq);