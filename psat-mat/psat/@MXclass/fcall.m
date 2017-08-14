function fcall(a)

global DAE Settings

if ~a.n, return, end

x = DAE.x(a.x);
y = DAE.x(a.y);
V1 = DAE.y(a.vbus);
t1 = DAE.y(a.bus);
Tfv = a.con(:,13);
Tft = a.con(:,14);
k = 0.5/pi/Settings.freq;
V0 = a.dat(:,1);
t0 = a.dat(:,2);

DAE.f(a.x) = a.u.*(-V1./Tfv-x)./Tfv;
DAE.f(a.y) = a.u.*(-k.*(t1-t0)./Tft-y)./Tft;
