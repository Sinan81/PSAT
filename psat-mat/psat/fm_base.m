function fm_base
%FM_BASE report component parameters to system bases
%
%FM_BASE
%
%see also FM_SPF
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    04-Jan-2007
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Areas Regions Shunt SW PV PQ Line Lines Fault Demand Supply
global Rmpg Rmpl Vltn Pl Mn Ltc Phs Tap Tg COI Svc Statcom Tcsc Sssc Upfc
global Hvdc Sofc SSR Ind Syn Mass Cswt Dfig Ddsg WTFR Spv Spq

Areas = base(Areas);
Regions = base(Regions);
Shunt = base(Shunt);
SW = base(SW);
PV = base(PV);
PQ = base(PQ);
Line = base(Line);
Lines = base(Lines);
Fault = base(Fault);
Demand = base(Demand);
Supply = base(Supply);
Rmpg = base(Rmpg);
Rmpl = base(Rmpl);
Vltn = base(Vltn);
Pl = base(Pl);
Mn = base(Mn);
Ltc = base(Ltc);
Phs = base(Phs);
Tap = base(Tap);
Tg = base(Tg);
Svc = base(Svc);
Statcom = base(Statcom);
Tcsc = base(Tcsc);
Sssc = base(Sssc);
Upfc = base(Upfc);
Hvdc = base(Hvdc);
Sofc = base(Sofc);
SSR = base(SSR);
Ind = base(Ind);
Syn = base(Syn);
COI = base(COI);
Mass = base(Mass);
Cswt = base(Cswt);
Dfig = base(Dfig);
Ddsg = base(Ddsg);
WTFR = base(WTFR);
Spv = base(Spv);
Spq = base(Spq);