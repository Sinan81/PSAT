function [Ps,Qs,Pr,Qr] = flows(a,Ps,Qs,Pr,Qr,varargin)

global DAE

if ~a.n, return, end

if nargin == 5
  type = 'all';
else
  type = varargin{1};
end

V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);
cc = cos(DAE.y(a.bus1)-DAE.y(a.bus2));
den = max(sqrt(V1.^2+V2.^2-2.*V1.*V2.*cc),1e-6*ones(a.n,1));
u = a.u.*DAE.x(a.vcs)./den;
switch type
 case 'all'
  Ps(a.line) = (1+u).*Ps(a.line);
  Pr(a.line) = (1+u).*Pr(a.line);
  Qs(a.line) = (1+u).*Qs(a.line);
  Qr(a.line) = (1+u).*Qr(a.line);
 case 'sssc'
  Ps = (1+u).*Ps;
  Pr = (1+u).*Pr;
  Qs = (1+u).*Qs;
  Qr = (1+u).*Qr;
end
