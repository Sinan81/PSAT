function Fxcall(p)

global DAE

if ~p.n, return, end

q1 = DAE.x(p.q1);
KI = p.con(:,6);

u = p.u & q1 < p.con(:,8) & q1 > p.con(:,9);

DAE.Gx = DAE.Gx + sparse(p.q,p.q1,u,DAE.m,DAE.n);
DAE.Fx = DAE.Fx - sparse(p.q1,p.q1,~u,DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(p.q1,p.vbus,-KI.*u,DAE.n,DAE.m);
