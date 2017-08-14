function [x,y] = fm_getxy(idx)
% FM_GETXY finds state and algebraic variables within selected zones
%
% [X,Y] = FM_GETXY(IDX)
%         IDX  bus indexes
%         X    indices of state variables
%         Y    indices of algebraic variables
%
%Author:    Federico Milano
%Date:      27-May-2008
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Busfreq COI Cluster Cac Cswt Ddsg Dfig Mass Exload Sofc Fl
global Hvdc Ind Jimma Ltc Phs Mixload Exc Oxl Pmu Pod Pss SSR Sssc
global Statcom Svc Syn Tcsc Upfc Tg Thload Tap WTFR Spv Spq

x = [];
y = [];

[x,y] = getxy_busfreq(Busfreq,idx,x,y);
[x,y] = getxy_coi(COI,idx,x,y);
[x,y] = getxy_cluster(Cluster,idx,x,y);
[x,y] = getxy_cac(Cac,idx,x,y);
[x,y] = getxy_cswt(Cswt,idx,x,y);
[x,y] = getxy_ddsg(Ddsg,idx,x,y);
[x,y] = getxy_dfig(Dfig,idx,x,y);
[x,y] = getxy_mass(Mass,idx,x,y);
[x,y] = getxy_exload(Exload,idx,x,y);
[x,y] = getxy_sofc(Sofc,idx,x,y);
[x,y] = getxy_fl(Fl,idx,x,y);
[x,y] = getxy_hvdc(Hvdc,idx,x,y);
[x,y] = getxy_ind(Ind,idx,x,y);
[x,y] = getxy_jimma(Jimma,idx,x,y);
[x,y] = getxy_ltc(Ltc,idx,x,y);
[x,y] = getxy_phs(Phs,idx,x,y);
[x,y] = getxy_mixload(Mixload,idx,x,y);
[x,y] = getxy_exc(Exc,idx,x,y);
[x,y] = getxy_oxl(Oxl,idx,x,y);
[x,y] = getxy_pmu(Pmu,idx,x,y);
[x,y] = getxy_pod(Pod,idx,x,y);
[x,y] = getxy_pss(Pss,idx,x,y);
[x,y] = getxy_ssr(SSR,idx,x,y);
[x,y] = getxy_sssc(Sssc,idx,x,y);
[x,y] = getxy_statcom(Statcom,idx,x,y);
[x,y] = getxy_svc(Svc,idx,x,y);
[x,y] = getxy_syn(Syn,idx,x,y);
[x,y] = getxy_tcsc(Tcsc,idx,x,y);
[x,y] = getxy_upfc(Upfc,idx,x,y);
[x,y] = getxy_tg(Tg,idx,x,y);
[x,y] = getxy_thload(Thload,idx,x,y);
[x,y] = getxy_tap(Tap,idx,x,y);
[x,y] = getxy_wtfr(WTFR,idx,x,y);
[x,y] = getxy_spv(Spv,idx,x,y);
[x,y] = getxy_spq(Spq,idx,x,y);