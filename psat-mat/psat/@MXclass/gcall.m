function gcall(a)

global DAE Settings

if ~a.n, return, end

x = DAE.x(a.x);
y = DAE.x(a.y);
V1 = DAE.y(a.vbus);
t1 = DAE.y(a.bus);
Kpf = a.con(:,5);
Kpv = a.con(:,6);
alpha = a.con(:,7);
Tpv = a.con(:,8);
Kqf = a.con(:,9);
Kqv = a.con(:,10);
beta = a.con(:,11);
Tqv = a.con(:,12);
Tfv = a.con(:,13);
Tft = a.con(:,14);
k = 0.5/pi/Settings.freq;
V0 = a.dat(:,1);
t0 = a.dat(:,2);


DAE.g = DAE.g + ...
        sparse(a.bus,1,a.u.*(Kpf.*(y+k.*(t1-t0)./Tft)+Kpv.*((V1./V0).^alpha+Tpv.*(x+V1./Tfv))),DAE.m,1) + ...
        sparse(a.vbus,1,a.u.*(Kqf.*(y+k.*(t1-t0)./Tft)+Kqv.*((V1./V0).^beta+Tqv.*(x+V1./Tfv))),DAE.m,1);

