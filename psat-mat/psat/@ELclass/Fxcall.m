function Fxcall(a)

global DAE

if ~a.n, return, end

xp = DAE.x(a.xp);
xq = DAE.x(a.xq);
V = DAE.y(a.vbus);
Tp = a.con(:,5);
Tq = a.con(:,6);
as = a.con(:,7);
at = a.con(:,8);
bs = a.con(:,9);
bt = a.con(:,10);
P0 = a.u.*a.dat(:,1);
Q0 = a.u.*a.dat(:,2);
V0 = a.dat(:,3);

DAE.Fx = DAE.Fx - sparse(a.xp,a.xp,a.u./Tp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.xq,a.xq,a.u./Tq,DAE.n,DAE.n);

DAE.Fy = DAE.Fy + sparse(a.xp,a.vbus, ...
                         P0.*(V./V0).^(as-1).*as./V0 - P0.*(V./V0).^(at-1).*at./V0, ...
                         DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.xq,a.vbus, ...
                         Q0.*(V./V0).^(bs-1).*bs./V0 - Q0.*(V./V0).^(bt-1).*bt./V0, ...
                         DAE.n,DAE.m);

DAE.Gx = DAE.Gx + sparse(a.bus,a.xp,a.u./Tp,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.vbus,a.xq,a.u./Tq,DAE.m,DAE.n);
