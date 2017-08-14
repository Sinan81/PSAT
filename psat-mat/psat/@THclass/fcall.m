function fcall(a)

global DAE

if ~a.n, return, end

T = DAE.x(a.T);
x = DAE.x(a.x);
G = DAE.y(a.G);
V = DAE.y(a.vbus);
Ki = a.con(:,4);
Ti = a.con(:,5);
T1 = a.con(:,6);
Ta = a.con(:,7);
Tref = a.con(:,8);
K1 = a.con(:,10);

DAE.f(a.T) = a.u.*(Ta - T + K1.*G.*V.^2)./T1;
DAE.f(a.x) = a.u.*Ki.*(Tref-T)./Ti;

% anti-windup limits
fm_windup(a.x,a.con(:,9),0,'f')
