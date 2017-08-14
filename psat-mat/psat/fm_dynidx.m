function fm_dynidx
% FM_DYNIDX define indices of state variables for components
%           which are not initialized during the power flow
%           analysis
%
% FM_DYNIDX
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    17-Jul-2007
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global DAE
global Syn Exc Tg Oxl Pss Fl Thload Svc Statcom Tcsc Sssc Upfc Mass SSR
global Sofc Cac Cluster Exload Wind Cswt Dfig Busfreq Pmu Pod COI Jimma
global Mixload Ddsg WTFR Spv Spq

Syn = dynidx(Syn);
Exc = dynidx(Exc);
Tg = dynidx(Tg);
Oxl = dynidx(Oxl);
Pss = dynidx(Pss);
Fl = dynidx(Fl);
Thload = dynidx(Thload);
Svc = dynidx(Svc);
Statcom = dynidx(Statcom);
Tcsc = dynidx(Tcsc);
Sssc = dynidx(Sssc);
Upfc = dynidx(Upfc);
Mass = dynidx(Mass);
SSR = dynidx(SSR);
Sofc = dynidx(Sofc);
Cac = dynidx(Cac);
Cluster = dynidx(Cluster);
Exload = dynidx(Exload);
Wind = dynidx(Wind);
Cswt = dynidx(Cswt);
Dfig = dynidx(Dfig);
Ddsg = dynidx(Ddsg);
Busfreq = dynidx(Busfreq);
Pmu = dynidx(Pmu);
Pod = dynidx(Pod);
COI = dynidx(COI);
Jimma = dynidx(Jimma);
Mixload = dynidx(Mixload);
WTFR = dynidx(WTFR);
Spv = dynidx(Spv);
Spq = dynidx(Spq);