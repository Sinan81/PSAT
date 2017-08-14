function Gycall(a)

global DAE

if ~a.n, return, end

omega_m = DAE.x(a.omega_m);
iqs = DAE.x(a.iqs);
idc = DAE.x(a.idc);
iqc = DAE.y(a.iqc);

V = DAE.y(a.vbus);
t = DAE.y(a.bus);
ids = DAE.y(a.ids);

rs = a.con(:,6);
xd = a.con(:,7);
xq = a.con(:,8);
psip = a.con(:,9);

c1 = cos(t);
s1 = sin(t);
t1 = s1./c1;

vds = -rs.*ids+omega_m.*xq.*iqs;
vqs = -rs.*iqs-omega_m.*(xd.*ids-psip);
ps = vds.*ids+vqs.*iqs;
%qc = V.*idc./c1+t1.*ps;
iq = (ps + V.*s1.*idc)./V./c1;
qc = V.*(idc.*c1+iqc.*s1);
uq = qc < a.con(:,23) & qc > a.con(:,24) & a.u;
uc = iq < a.con(:,21) & iq > a.con(:,22) & a.u;
dps_dids = -2*rs.*ids+omega_m.*(xq-xd).*iqs;

DAE.Gy = DAE.Gy ...
         - sparse(a.bus,a.ids,dps_dids,DAE.m,DAE.m) ...
         - sparse(a.vbus,a.vbus,uq.*(idc.*c1+iqc.*s1),DAE.m,DAE.m) ...
         + sparse(a.vbus,a.bus,uq.*(idc.*s1-iqc.*c1).*V,DAE.m,DAE.m) ...
         - sparse(a.vbus,a.iqc,uq.*V.*s1,DAE.m,DAE.m) ...
         - sparse(a.iqc,a.iqc,1,DAE.m,DAE.m) ...
         - sparse(a.iqc,a.vbus,uc.*ps./V./V./c1,DAE.m,DAE.m) ...
         + sparse(a.iqc,a.bus,uc.*(ps./V./c1./c1.*s1+idc.*(1+t1.*t1)),DAE.m,DAE.m) ...
         + sparse(a.iqc,a.ids,uc.*dps_dids./V./c1,DAE.m,DAE.m) ...
         + sparse(a.ids,a.ids,omega_m.*(psip-2*xd.*ids),DAE.m,DAE.m) ...
         - sparse(a.pwa, a.pwa, 1, DAE.m, DAE.m);
