function Gycall(a)

global DAE

if ~a.n, return, end

V  = DAE.y(a.vbus);
at = a.con(:,8);
bt = a.con(:,10);
P0 = a.dat(:,1);
Q0 = a.dat(:,2);
V0 = a.dat(:,3);

DAE.Gy = DAE.Gy + sparse(a.bus,a.vbus,a.u.*P0.* ...
                           (V./V0).^(at-1).*at./V0,DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.vbus,a.vbus,a.u.*Q0.* ...
                           (V./V0).^(bt-1).*bt./V0,DAE.m,DAE.m);
