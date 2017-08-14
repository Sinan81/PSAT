function Gycall(a)

global DAE

if ~a.n, return, end

Ik = DAE.x(a.Ik);
Vk = DAE.x(a.Vk);
m = DAE.x(a.m);
Vs = DAE.y(a.vbus);
Sn = a.con(:,2);
Vn = a.con(:,3);
xt = a.con(:,26);

Vt = m.*Vk.*a.con(:,24);
sq = sqrt(1-(xt.*Ik./Vs.*Vn./Sn./m).^2);
dQdv = -2*Vs./xt+Vt./xt.*sq+0.5*Vs.*Vt./xt.*(2*((xt.*Ik.*Vn./Sn./m).^2)./(Vs.^3))./sq;
DAE.Gy = DAE.Gy - sparse(a.vbus,a.vbus,a.u.*dQdv,DAE.m,DAE.m);
