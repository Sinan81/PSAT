function fm_ncomp
% FM_NCOMP search components used in the current data
%          file and initializes fields used for power
%          flow computations.
%
% CHECK = FM_NCOMP
%
%see also FM_SLF
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    22-Feb-2003
%Version:   1.0.1
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Settings
global Bus Areas Regions Shunt SW PV PQ PQgen Line Lines Twt Fl Mn
global Demand Supply Pl Syn Mass Exc Fault Breaker Ind Thload Tg COI
global Ltc Tap Oxl Pss Mass SSR Svc Statcom Tcsc Sssc Upfc Hvdc Pod
global Rmpg Rmpl Rsrv Vltn Ypdp Sofc Cac Cluster Exload Phs Wind Cswt
global Dfig Ddsg Busfreq Mixload Jimma Pmu WTFR Spv Spq

Settings.ok = 1;

% setup components
Bus = setup(Bus);
Line = setup(Line);
Lines = setup(Lines);
Twt = setup(Twt);
Shunt = setup(Shunt);
Fault = setup(Fault);
Breaker = setup(Breaker);
PV = setup(PV);
SW = setup(SW);
Areas = setup(Areas);
Regions = setup(Regions);
PQ = setup(PQ);
PQgen = setup(PQgen);
PQ = addgen(PQ,PQgen);
Pl = setup(Pl);
Mn = setup(Mn);
Fl = setup(Fl);
Ind = setup(Ind);
Thload = setup(Thload);
Tap = setup(Tap);
Syn = setup(Syn);
Exc = setup(Exc);
Tg = setup(Tg);
Oxl = setup(Oxl);
Pss = setup(Pss);
Ltc = setup(Ltc);
Svc  = setup(Svc);
Statcom = setup(Statcom);
Tcsc = setup(Tcsc);
Sssc = setup(Sssc);
Upfc = setup(Upfc);
Hvdc = setup(Hvdc);
Demand = setup(Demand);
Supply = setup(Supply);
Rmpg = setup(Rmpg);
Rmpl = setup(Rmpl);
Rsrv = setup(Rsrv);
Vltn = setup(Vltn);
Ypdp = setup(Ypdp);
Mass = setup(Mass);
SSR = setup(SSR);
Pod = setup(Pod);
COI = setup(COI);

% ----------------------------------------------------------- %
%                       W A R N I N G                         %
% ----------------------------------------------------------- %
% Following lines have been written by the UDM build utility. %
% This utility requires you do NOT change anything beyond     %
% this point in order to be able to correctly install and     %
% uninstall UDMs.                                             %
% ----------------------------------------------------------- %

Sofc = setup(Sofc);
Cac = setup(Cac);
Cluster = setup(Cluster);
Exload = setup(Exload);
Phs = setup(Phs);
Wind = setup(Wind);
Cswt = setup(Cswt);
Dfig = setup(Dfig);
Ddsg = setup(Ddsg);
Busfreq = setup(Busfreq);
Pmu = setup(Pmu);
Jimma = setup(Jimma);
Mixload = setup(Mixload);
WTFR = setup(WTFR);
Spv = setup(Spv);
Spq = setup(Spq);