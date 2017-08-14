function Gycall(a)

global DAE

if ~a.n, return, end

V1 = DAE.y(a.vbus);
Tf = a.con(:,5);
Plz = a.con(:,6);
Pli = a.con(:,7);
Qlz = a.con(:,9);
Qli = a.con(:,10);
Kv = a.con(:,12);
V1_0 = a.dat(:,1);

DAE.Gy = DAE.Gy + sparse(a.bus,a.vbus, ...
                           a.u.*(2.*Plz.*V1./V1_0.^2+Pli./V1_0),DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.vbus,a.vbus, ...
                           a.u.*(2.*Qlz.*V1./V1_0.^2+Qli./V1_0+Kv./Tf),DAE.m,DAE.m);
