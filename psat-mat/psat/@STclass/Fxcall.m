function Fxcall(a)

global DAE

if ~a.n, return, end

V = DAE.y(a.vbus);
ist = DAE.x(a.ist);
Kr = a.con(:,5);
Tr = a.con(:,6);
ist_max = a.con(:,7);
ist_min = a.con(:,8);

DAE.Fx = DAE.Fx - sparse(a.ist,a.ist,a.u./Tr,DAE.n,DAE.n);     
DAE.Fy = DAE.Fy + sparse(a.ist,a.vref,a.u.*Kr./Tr,DAE.n,DAE.m);     

u = (ist <= ist_max & ist >= ist_min & a.u);

DAE.Gx = DAE.Gx - sparse(a.vbus,a.ist,u.*V,DAE.m,DAE.n);
DAE.Fy = DAE.Fy - sparse(a.ist,a.vbus,u.*Kr./Tr,DAE.n,DAE.m);
