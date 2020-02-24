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
% Copyright (C) 2002-2019 Federico Milano

global Areas Regions Shunt SW PV PQ Line Lines Fault Demand Supply
global Rmpg Rmpl Vltn Pl Mn Ltc Phs Tap Tg COI Svc Statcom Tcsc Sssc Upfc
global Hvdc Sofc SSR Ind Syn Mass Cswt Dfig Ddsg WTFR Spv Spq

Areas = base_areas(Areas);
Regions = base_areas(Regions);
Shunt = base_shunt(Shunt);
SW = base_sw(SW);
PV = base_pv(PV);
PQ = base_pq(PQ);
Line = base_line(Line);
Lines = base_lines(Lines);
Fault = base_fault(Fault);
Demand = base_demand(Demand);
Supply = base_supply(Supply);
Rmpg = base_rmpg(Rmpg);
Rmpl = base_rmpl(Rmpl);
Vltn = base_vltn(Vltn);
Pl = base_pl(Pl);
Mn = base_mn(Mn);
Ltc = base_ltc(Ltc);
Phs = base_phs(Phs);
Tap = base_tap(Tap);
Tg = base_tg(Tg);
Svc = base_svc(Svc);
Statcom = base_statcom(Statcom);
Tcsc = base_tcsc(Tcsc);
Sssc = base_sssc(Sssc);
Upfc = base_upfc(Upfc);
Hvdc = base_hvdc(Hvdc);
Sofc = base_sofc(Sofc);
SSR = base_ssr(SSR);
Ind = base_ind(Ind);
Syn = base_syn(Syn);
COI = base_coi(COI);
Mass = base_mass(Mass);
Cswt = base_cswt(Cswt);
Dfig = base_dfig(Dfig);
Ddsg = base_ddsg(Ddsg);
WTFR = base_wtfr(WTFR);
Spv = base_spv(Spv);
Spq = base_spq(Spq);
