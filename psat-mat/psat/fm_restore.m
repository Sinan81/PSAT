% FM_RESTORE reset all component data using the "store" field
%
% FM_RESTORE
%
%see also RUNPSAT
%
%Author:    Federico Milano
%Update:    13-Jun-2008
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

fm_inilf

Bus = restore(Bus);
Line = restore(Line);
Lines = restore(Lines);
Twt = restore(Twt);
Shunt = restore(Shunt);
Fault = restore(Fault);
Breaker = restore(Breaker);
PV = restore(PV);
SW = restore(SW);
Areas = restore(Areas);
Regions = restore(Regions);
PQgen = restore(PQgen,0);
PQ = restore(PQ);
Pl = restore(Pl);
Mn = restore(Mn);
Fl = restore(Fl);
Ind = restore(Ind);
Thload = restore(Thload);
Tap = restore(Tap);
Syn = restore(Syn);
Exc = restore(Exc);
Tg = restore(Tg);
Oxl = restore(Oxl);
Pss = restore(Pss);
Ltc = restore(Ltc);
Svc  = restore(Svc);
Statcom = restore(Statcom);
Tcsc = restore(Tcsc);
Sssc = restore(Sssc);
Upfc = restore(Upfc);
Hvdc = restore(Hvdc);
Demand = restore(Demand);
Supply = restore(Supply);
Rmpg = restore(Rmpg);
Rmpl = restore(Rmpl);
Rsrv = restore(Rsrv);
Vltn = restore(Vltn);
Ypdp = restore(Ypdp);
Mass = restore(Mass);
SSR = restore(SSR);
Pod = restore(Pod);
COI = setup(COI);

% ----------------------------------------------------------- %
%                       W A R N I N G                         %
% ----------------------------------------------------------- %
% Following lines were written by the UDM build utility.      %
% This utility requires you do NOT change anything beyond     %
% this point in order to be able to correctly install and     %
% uninstall UDMs.                                             %
% ----------------------------------------------------------- %

Sofc = restore(Sofc);
Cac = restore(Cac);
Cluster = restore(Cluster);
Exload = restore(Exload);
Phs = restore(Phs);
Wind = restore(Wind);
Cswt = restore(Cswt);
Dfig = restore(Dfig);
Ddsg = restore(Ddsg);
Busfreq = restore(Busfreq);
Pmu = restore(Pmu);
Jimma = restore(Jimma);
Mixload = restore(Mixload);
WTFR = restore(WTFR);
Spv = restore(Spv);
Spq = restore(Spq);