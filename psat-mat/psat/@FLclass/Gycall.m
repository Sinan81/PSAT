function Gycall(a)

global DAE Settings

if ~a.n, return, end

V = DAE.y(a.vbus);
dw = DAE.y(a.dw);
P0 = a.u.*a.con(:,2);
Q0 = a.u.*a.con(:,5);
ap = a.con(:,3);
aq = a.con(:,6);
bp = a.con(:,4);
bq = a.con(:,7);

DAE.Gy = DAE.Gy + sparse(a.bus,a.dw,P0.*V.^ap.*bp.*(1+dw).^(bp-1),DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.bus,a.vbus,P0.*ap.*V.^(ap-1).*(1+dw).^bp,DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.vbus,a.dw,Q0.*V.^aq.*bq.*(1+dw).^(bq-1),DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.vbus,a.vbus,Q0.*aq.*V.^(aq-1).*(1+dw).^bq,DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.dw,a.bus,a.u./a.con(:,8)/(2*pi*Settings.freq),DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.dw,a.dw,1,DAE.m,DAE.m);
