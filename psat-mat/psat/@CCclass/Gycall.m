function Gycall(p)

global DAE

if ~p.n, return, end

KP = p.u.*p.con(:,7);

DAE.Gy = DAE.Gy - sparse(p.q,p.q,1,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(p.q,p.vbus,KP,DAE.m,DAE.m);
