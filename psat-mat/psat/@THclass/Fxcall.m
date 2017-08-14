function Fxcall(a)

global DAE

if ~a.n, return, end

T = DAE.x(a.T);
x = DAE.x(a.x);
G = DAE.y(a.G);
V = a.u.*DAE.y(a.vbus);
Kp = a.u.*a.con(:,3);
Ki = a.u.*a.con(:,4);
Ti = a.con(:,5);
T1 = a.con(:,6);
Ta = a.con(:,7);
Tref = a.con(:,8);
G_max = a.con(:,9);
K1 = a.con(:,10);

DAE.Fx = DAE.Fx - sparse(a.T,a.T,a.u./T1,DAE.n,DAE.n);
z = x < G_max & x > 0 & a.u;
DAE.Fx = DAE.Fx - sparse(a.x,a.T,z.*Ki./Ti,DAE.n,DAE.n);

DAE.Fy = DAE.Fy + sparse(a.T,a.G,K1.*V.^2./T1,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.T,a.vbus,2*K1.*G.*V./T1,DAE.n,DAE.m);

z = G < G_max & G > 0 & a.u;
DAE.Gx = DAE.Gx - sparse(a.G,a.T,a.u.*Kp.*z,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.G,a.x,z,DAE.m,DAE.n);
