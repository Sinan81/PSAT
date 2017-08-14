function [Ps,Qs,Pr,Qr] = flows(a,Ps,Qs,Pr,Qr,varargin)

global DAE

if ~a.n, return, end

if nargin == 5
  type = 'all';
else
  type = varargin{1};
end

g = fgamma(a);
V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);
theta = DAE.y(a.bus1)-DAE.y(a.bus2)+g;
ss = sin(theta);
cc = cos(theta);
c1 = a.u.*sqrt(DAE.x(a.vp).^2+DAE.x(a.vq).^2).*a.y;
switch type
 case 'all'
  Ps(a.line) = Ps(a.line) + c1.*V2.*ss;
  Qs(a.line) = Qs(a.line) + c1.*V1.*cos(g);
  Pr(a.line) = Pr(a.line) - c1.*V2.*ss;
  Qr(a.line) = Qr(a.line) - c1.*V2.*cc;
 case 'upfc'
  Ps = Ps + c1.*V2.*ss;
  Qs = Qs + c1.*V1.*cos(g);
  Pr = Pr - c1.*V2.*ss;
  Qr = Qr - c1.*V2.*cc;  
end
