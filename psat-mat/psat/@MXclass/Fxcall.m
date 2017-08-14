function Fxcall(a)

global DAE Settings

if ~a.n, return, end

Kpf = a.con(:,5);
Kpv = a.con(:,6);
Tpv = a.con(:,8);
Kqf = a.con(:,9);
Kqv = a.con(:,10);
Tpv = a.con(:,8);
Tqv = a.con(:,12);
Tfv = a.con(:,13);
Tft = a.con(:,14);
k = 0.5/pi/Settings.freq;

DAE.Fx = DAE.Fx + sparse(a.x,a.x,-a.u./Tfv,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.y,a.y,-a.u./Tft,DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(a.x,a.vbus,-a.u./Tfv./Tfv,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.y,a.bus,-k*a.u./Tft./Tft,DAE.n,DAE.m);
DAE.Gx = DAE.Gx + sparse(a.bus,a.x,a.u.*Kpv.*Tpv,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.bus,a.y,a.u.*Kpf,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.vbus,a.x,a.u.*Kqv.*Tqv,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.vbus,a.y,a.u.*Kqf,DAE.m,DAE.n);
