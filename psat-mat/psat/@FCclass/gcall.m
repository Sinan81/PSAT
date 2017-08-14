function gcall(a)

global DAE

if ~a.n, return, end

Ik = DAE.x(a.Ik);
Vk = DAE.x(a.Vk);
m = DAE.x(a.m);
Vs = DAE.y(a.vbus);
Sn = a.con(:,2);
Vn = a.con(:,3);
Vbas = a.con(:,24);
xt = a.con(:,26);

DAE.g = DAE.g - sparse(a.bus,1,a.u.*Ik.*Vk.*Vn./Sn.*Vbas,DAE.m,1);
Vt = m.*Vk.*Vbas;
Q = -Vs.*(Vs - Vt.*sqrt(1-(xt.*Ik./Vs.*Vn./Sn./m).^2))./xt;
DAE.g = DAE.g - sparse(a.vbus,1,a.u.*Q,DAE.m,1);
