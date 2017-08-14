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
Bus = init(Bus);
Areas = init(Areas);
Regions = init(Regions);
Shunt = init(Shunt);
SW = init(SW);
PV = init(PV);
PQ = init(PQ);
PQgen = init(PQgen);
Line = init(Line);
Lines = init(Lines);
Twt = init(Twt);
Fl = init(Fl);
Demand = init(Demand);
Supply = init(Supply);
Mn = init(Mn);
Pl = init(Pl);
Syn = init(Syn);
Mass = init(Mass);
Exc = init(Exc);
Fault = init(Fault);
Breaker = init(Breaker);
Ind = init(Ind);
Thload = init(Thload);
Tg = init(Tg);
COI = init(COI);
Ltc = init(Ltc);
Tap = init(Tap);
Oxl = init(Oxl);
Pss = init(Pss);
Mass = init(Mass);
SSR = init(SSR);

% FACTS
Svc = init(Svc);
Statcom = init(Statcom);
Tcsc = init(Tcsc);
Sssc = init(Sssc);
Upfc = init(Upfc);
Hvdc = init(Hvdc);
Pod = init(Pod);

% Market data
Rmpg = init(Rmpg);
Rmpl = init(Rmpl);
Rsrv = init(Rsrv);
Vltn = init(Vltn);
Ypdp = init(Ypdp);

% ----------------------------------------------------------- %
%                       W A R N I N G                         %
% ----------------------------------------------------------- %
% Following lines have been written by the UDM build utility. %
% This utility requires you do NOT change anything beyond     %
% this point in order to be able to correctly install and     %
% uninstall UDMs.                                             %
% ----------------------------------------------------------- %

Sofc = init(Sofc);

Cac = init(Cac);
Cluster = init(Cluster);

Exload = init(Exload);
Phs = init(Phs);

Wind = init(Wind);
Cswt = init(Cswt);
Dfig = init(Dfig);
Ddsg = init(Ddsg);

Busfreq = init(Busfreq);
Pmu = init(Pmu);
Mixload = init(Mixload);
Jimma = init(Jimma);
WTFR = init(WTFR);
Spv = init(Spv);
Spq = init(Spq);