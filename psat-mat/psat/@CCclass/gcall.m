function gcall(p)

global DAE

if ~p.n, return, end

q1 = DAE.x(p.q1);
V1 = DAE.y(p.vbus);
Vpref = p.con(:,5);
KI = p.con(:,6);
KP = p.u.*p.con(:,7);

DAE.g = DAE.g + sparse(p.q,1,q1+KP.*(Vpref-V1)-DAE.y(p.q),DAE.m,1);
