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

Bus = restore_bus(Bus);
Line = restore_line(Line);
Lines = restore_lines(Lines);
Twt = restore_twt(Twt);
Shunt = restore_shunt(Shunt);
Fault = restore_fault(Fault);
Breaker = restore_breaker(Breaker);
PV = restore_pv(PV);
SW = restore_sw(SW);
Areas = restore_areas(Areas);
Regions = restore_areas(Regions);
PQgen = restore_pq(PQgen,0);
PQ = restore_pq(PQ);
Pl = restore_pl(Pl);
Mn = restore_mn(Mn);
Fl = restore_fl(Fl);
Ind = restore_ind(Ind);
Thload = restore_thload(Thload);
Tap = restore_tap(Tap);
Syn = restore_syn(Syn);
Exc = restore_exc(Exc);
Tg = restore_tg(Tg);
Oxl = restore_oxl(Oxl);
Pss = restore_pss(Pss);
Ltc = restore_ltc(Ltc);
Svc  = restore_svc(Svc);
Statcom = restore_statcom(Statcom);
Tcsc = restore_tcsc(Tcsc);
Sssc = restore_sssc(Sssc);
Upfc = restore_upfc(Upfc);
Hvdc = restore_hvdc(Hvdc);
Demand = restore_demand(Demand);
Supply = restore_supply(Supply);
Rmpg = restore_rmpg(Rmpg);
Rmpl = restore_rmpl(Rmpl);
Rsrv = restore_rsrv(Rsrv);
Vltn = restore_vltn(Vltn);
Ypdp = restore_ypdp(Ypdp);
Mass = restore_mass(Mass);
SSR = restore_ssr(SSR);
Pod = restore_pod(Pod);
COI = setup_coi(COI);

% ----------------------------------------------------------- %
%                       W A R N I N G                         %
% ----------------------------------------------------------- %
% Following lines were written by the UDM build utility.      %
% This utility requires you do NOT change anything beyond     %
% this point in order to be able to correctly install and     %
% uninstall UDMs.                                             %
% ----------------------------------------------------------- %

Sofc = restore_sofc(Sofc);
Cac = restore_cac(Cac);
Cluster = restore_cluster(Cluster);
Exload = restore_exload(Exload);
Phs = restore_phs(Phs);
Wind = restore_wind(Wind);
Cswt = restore_cswt(Cswt);
Dfig = restore_dfig(Dfig);
Ddsg = restore_ddsg(Ddsg);
Busfreq = restore_busfreq(Busfreq);
Pmu = restore_pmu(Pmu);
Jimma = restore_jimma(Jimma);
Mixload = restore_mixload(Mixload);
WTFR = restore_wtfr(WTFR);
Spv = restore_spv(Spv);
Spq = restore_spq(Spq);