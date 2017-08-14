function Fxcall(p)

global DAE

if ~p.n, return, end

Vs = DAE.x(p.Vs);
u = p.u & Vs < p.con(:,8) & Vs > p.con(:,9);

DAE.Gx = DAE.Gx + sparse(p.vref,p.Vs,u,DAE.m,DAE.n);
DAE.Fx = DAE.Fx - sparse(p.Vs,p.Vs,~u,DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(p.Vs,p.cac,u.*p.con(:,7).*p.dVsdQ,DAE.n,DAE.m) ...
         - sparse(p.Vs,p.q,u.*p.dVsdQ,DAE.n,DAE.m);
