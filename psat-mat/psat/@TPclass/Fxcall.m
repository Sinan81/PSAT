function Fxcall(p)

global DAE

if ~p.n, return, end

m = DAE.x(p.m);
V = DAE.y(p.vbus);
h = p.con(:,4);

u = m < p.con(:,6) & m > p.con(:,7) & p.u;

k = u.*p.con(:,5);
a = u.*p.con(:,11);
b = u.*p.con(:,12);

DAE.Fx = DAE.Fx - sparse(p.m,p.m,h+V.*k./m./m,DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(p.m,p.vbus,k./m,DAE.n,DAE.m);
DAE.Gx = DAE.Gx - sparse(p.bus,p.m,p.con(:,9).*a.*(V.^a)./(m.^(a+1)),DAE.m,DAE.n);
DAE.Gx = DAE.Gx - sparse(p.vbus,p.m,p.con(:,10).*b.*(V.^b)./(m.^(b+1)),DAE.m,DAE.n);
