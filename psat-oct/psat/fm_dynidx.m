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
% Copyright (C) 2002-2019 Federico Milano

global DAE
global Syn Exc Tg Oxl Pss Fl Thload Svc Statcom Tcsc Sssc Upfc Mass SSR
global Sofc Cac Cluster Exload Wind Cswt Dfig Busfreq Pmu Pod COI Jimma
global Mixload Ddsg WTFR Spv Spq

Syn = dynidx_syn(Syn);
Exc = dynidx_exc(Exc);
Tg = dynidx_tg(Tg);
Oxl = dynidx_oxl(Oxl);
Pss = dynidx_pss(Pss);
Fl = dynidx_fl(Fl);
Thload = dynidx_thload(Thload);
Svc = dynidx_svc(Svc);
Statcom = dynidx_statcom(Statcom);
Tcsc = dynidx_tcsc(Tcsc);
Sssc = dynidx_sssc(Sssc);
Upfc = dynidx_upfc(Upfc);
Mass = dynidx_mass(Mass);
SSR = dynidx_ssr(SSR);
Sofc = dynidx_sofc(Sofc);
Cac = dynidx_cac(Cac);
Cluster = dynidx_cluster(Cluster);
Exload = dynidx_exload(Exload);
Wind = dynidx_wind(Wind);
Cswt = dynidx_cswt(Cswt);
Dfig = dynidx_dfig(Dfig);
Ddsg = dynidx_ddsg(Ddsg);
Busfreq = dynidx_busfreq(Busfreq);
Pmu = dynidx_pmu(Pmu);
Pod = dynidx_pod(Pod);
COI = dynidx_coi(COI);
Jimma = dynidx_jimma(Jimma);
Mixload = dynidx_mixload(Mixload);
WTFR = dynidx_wtfr(WTFR);
Spv = dynidx_spv(Spv);
Spq = dynidx_spq(Spq);
