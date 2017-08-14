function gcall(a)

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

p1 = V1.*V1.*g12 - V12.*(g12.*cos12 + b12.*sin12);
p2 = V2.*V2.*g12 - V12.*(g12.*cos12 - b12.*sin12);
q1 = -V1.*V1.*(b12+bL2) - V12.*(g12.*sin12 - b12.*cos12);
q2 = -V2.*V2.*(b12+bL2) + V12.*(g12.*sin12 + b12.*cos12);

DAE.g = DAE.g + sparse(a.bus1,1,p1,DAE.m,1) ...
        + sparse(a.bus2,1,p2,DAE.m,1) ...
        + sparse(a.v1,1,q1,DAE.m,1) ...
        + sparse(a.v2,1,q2,DAE.m,1);
