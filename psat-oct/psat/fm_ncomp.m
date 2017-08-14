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
Bus = setup_bus(Bus);
Line = setup_line(Line);
Lines = setup_lines(Lines);
Twt = setup_twt(Twt);
Shunt = setup_shunt(Shunt);
Fault = setup_fault(Fault);
Breaker = setup_breaker(Breaker);
PV = setup_pv(PV);
SW = setup_sw(SW);
Areas = setup_areas(Areas);
Regions = setup_areas(Regions);
PQ = setup_pq(PQ);
PQgen = setup_pq(PQgen);
PQ = addgen_pq(PQ,PQgen);
Pl = setup_pl(Pl);
Mn = setup_mn(Mn);
Fl = setup_fl(Fl);
Ind = setup_ind(Ind);
Thload = setup_thload(Thload);
Tap = setup_tap(Tap);
Syn = setup_syn(Syn);
Exc = setup_exc(Exc);
Tg = setup_tg(Tg);
Oxl = setup_oxl(Oxl);
Pss = setup_pss(Pss);
Ltc = setup_ltc(Ltc);
Svc  = setup_svc(Svc);
Statcom = setup_statcom(Statcom);
Tcsc = setup_tcsc(Tcsc);
Sssc = setup_sssc(Sssc);
Upfc = setup_upfc(Upfc);
Hvdc = setup_hvdc(Hvdc);
Demand = setup_demand(Demand);
Supply = setup_supply(Supply);
Rmpg = setup_rmpg(Rmpg);
Rmpl = setup_rmpl(Rmpl);
Rsrv = setup_rsrv(Rsrv);
Vltn = setup_vltn(Vltn);
Ypdp = setup_ypdp(Ypdp);
Mass = setup_mass(Mass);
SSR = setup_ssr(SSR);
Pod = setup_pod(Pod);
COI = setup_coi(COI);

% ----------------------------------------------------------- %
%                       W A R N I N G                         %
% ----------------------------------------------------------- %
% Following lines have been written by the UDM build utility. %
% This utility requires you do NOT change anything beyond     %
% this point in order to be able to correctly install and     %
% uninstall UDMs.                                             %
% ----------------------------------------------------------- %

Sofc = setup_sofc(Sofc);
Cac = setup_cac(Cac);
Cluster = setup_cluster(Cluster);
Exload = setup_exload(Exload);
Phs = setup_phs(Phs);
Wind = setup_wind(Wind);
Cswt = setup_cswt(Cswt);
Dfig = setup_dfig(Dfig);
Ddsg = setup_ddsg(Ddsg);
Busfreq = setup_busfreq(Busfreq);
Pmu = setup_pmu(Pmu);
Jimma = setup_jimma(Jimma);
Mixload = setup_mixload(Mixload);
WTFR = setup_wtfr(WTFR);
Spv = setup_spv(Spv);
Spq = setup_spq(Spq);