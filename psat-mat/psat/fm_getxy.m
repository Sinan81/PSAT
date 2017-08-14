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

[x,y] = getxy(Busfreq,idx,x,y);
[x,y] = getxy(COI,idx,x,y);
[x,y] = getxy(Cluster,idx,x,y);
[x,y] = getxy(Cac,idx,x,y);
[x,y] = getxy(Cswt,idx,x,y);
[x,y] = getxy(Ddsg,idx,x,y);
[x,y] = getxy(Dfig,idx,x,y);
[x,y] = getxy(Mass,idx,x,y);
[x,y] = getxy(Exload,idx,x,y);
[x,y] = getxy(Sofc,idx,x,y);
[x,y] = getxy(Fl,idx,x,y);
[x,y] = getxy(Hvdc,idx,x,y);
[x,y] = getxy(Ind,idx,x,y);
[x,y] = getxy(Jimma,idx,x,y);
[x,y] = getxy(Ltc,idx,x,y);
[x,y] = getxy(Phs,idx,x,y);
[x,y] = getxy(Mixload,idx,x,y);
[x,y] = getxy(Exc,idx,x,y);
[x,y] = getxy(Oxl,idx,x,y);
[x,y] = getxy(Pmu,idx,x,y);
[x,y] = getxy(Pod,idx,x,y);
[x,y] = getxy(Pss,idx,x,y);
[x,y] = getxy(SSR,idx,x,y);
[x,y] = getxy(Sssc,idx,x,y);
[x,y] = getxy(Statcom,idx,x,y);
[x,y] = getxy(Svc,idx,x,y);
[x,y] = getxy(Syn,idx,x,y);
[x,y] = getxy(Tcsc,idx,x,y);
[x,y] = getxy(Upfc,idx,x,y);
[x,y] = getxy(Tg,idx,x,y);
[x,y] = getxy(Thload,idx,x,y);
[x,y] = getxy(Tap,idx,x,y);
[x,y] = getxy(WTFR,idx,x,y);
[x,y] = getxy(Spv,idx,x,y);
[x,y] = getxy(Spq,idx,x,y);