function fm_windup(idx,xmax,xmin,type)
% FM_WINDUP setup non-windup limiter for TDs
%
% FM_WINDUP(IDX,XMAX,XMIN,TYPE)
%       IDX  = index of state variables
%       XMAX = state variable upper limit
%       XMIN = state variable lower limit
%       TYPE = 'f'  for anti-windup limits of differential equations
%              'pf' for anti-windup limits during power flow analysis
%              'td' for modifying Ac during time domain simulations
%
%Author:    Federico Milano
%Date:      08-Mar-2006
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2006 Federico Milano

global DAE

x = DAE.x(idx);

switch type

 case 'f'

  if length(xmax) == 1, xmax = xmax*ones(length(idx),1); end
  if length(xmin) == 1, xmin = xmin*ones(length(idx),1); end

  k = find(x >= xmax & DAE.f(idx) > 0);
  if k
    DAE.f(idx(k)) = 0;
    DAE.x(idx(k)) = xmax(k);
  end

  k = find(x <= xmin & DAE.f(idx) < 0);
  if k
    DAE.f(idx(k)) = 0;
    DAE.x(idx(k)) = xmin(k);
  end

 case 'td'

  u = find((x >= xmax | x <= xmin) & DAE.f(idx) == 0);

  if ~isempty(u)
    k = idx(u);
    DAE.tn(k) = 0;
    DAE.Ac(k,:) = 0;
    DAE.Ac(:,k) = 0;
    DAE.Ac = DAE.Ac - sparse(k,k,1,DAE.m+DAE.n,DAE.m+DAE.n);
  end

 case 'pf'

  global Settings

  if length(xmax) == 1, xmax = xmax*ones(length(idx),1); end
  if length(xmin) == 1, xmin = xmin*ones(length(idx),1); end

  k = find(x >= xmax & (DAE.f(idx) > 0 | ~Settings.init));
  if k
    DAE.f(idx(k)) = 0;
    DAE.x(idx(k)) = xmax(k);
  end

  k = find(x <= xmin & (DAE.f(idx) < 0 | ~Settings.init));
  if k
    DAE.f(idx(k)) = 0;
    DAE.x(idx(k)) = xmin(k);
  end


end