function Gycall(a)

global DAE

if ~a.n, return, end

V1 = a.u.*DAE.y(a.v1);
V2 = a.u.*DAE.y(a.v2);
theta1 = DAE.y(a.bus1);
theta2 = DAE.y(a.bus2);
rl = a.con(:,6);
xl = a.con(:,7);
bl = a.con(:,8);
cos12 = cos(theta1-theta2);
sin12 = sin(theta1-theta2);
zl = rl.*rl+xl.*xl;
g12 = rl./zl;
b12 = -xl./zl;
bL2 = 0.5*bl;
V12 = V1.*V2;

c1 = g12.*cos12 + b12.*sin12;
c2 = g12.*sin12 - b12.*cos12;
c3 = g12.*cos12 - b12.*sin12;
c4 = g12.*sin12 + b12.*cos12;
c5 = b12 + bL2;

DAE.Gy = DAE.Gy + sparse(a.bus1,a.bus1, V12.*c2,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.bus1,a.bus2, V12.*c2,DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.bus2,a.bus1, V12.*c4,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.bus2,a.bus2, V12.*c4,DAE.m,DAE.m);

DAE.Gy = DAE.Gy + sparse(a.bus1,a.v1, 2*V1.*g12-V2.*c1,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.bus1,a.v2, V1.*c1,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.bus2,a.v1, V2.*c3,DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.bus2,a.v2, 2*V2.*g12-V1.*c3,DAE.m,DAE.m);

DAE.Gy = DAE.Gy - sparse(a.v1,a.v1, 2*V1.*c5+V2.*c2,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.v1,a.v2, V1.*c2,DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.v2,a.v1, V2.*c4,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.v2,a.v2, 2*V2.*c5-V1.*c4,DAE.m,DAE.m);

DAE.Gy = DAE.Gy - sparse(a.v1,a.bus1, V12.*c1,DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.v1,a.bus2, V12.*c1,DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.v2,a.bus1, V12.*c3,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.v2,a.bus2, V12.*c3,DAE.m,DAE.m);
