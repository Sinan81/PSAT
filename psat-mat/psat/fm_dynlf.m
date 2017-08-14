function fm_dynlf
% FM_DYNLF define state variable indices for components which are
%          included in power flow analysis
%
% FM_DYNLF
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    17-Jul-2007
%Update:    22-Nov-2007
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global DAE Ind Ltc Tap Hvdc Phs

DAE.n = 0;

Ind = dynidx(Ind);
Ltc = dynidx(Ltc);
Tap = dynidx(Tap);
Hvdc = dynidx(Hvdc);
Phs = dynidx(Phs);