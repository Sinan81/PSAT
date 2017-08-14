function Gycall(a)

global DAE

if ~a.n, return, end


id = DAE.x(a.id);
iq = DAE.x(a.iq);

V = DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);


vd = -V.*st;
vq =  V.*ct;



dPdtet = vd.*iq - vq.*id;
dPdv = iq.*ct - id.*st;
dQdtet = vd.*id + vq.*iq;
dQdv = id.*ct + iq.*st;

DAE.Gy = DAE.Gy - sparse(a.bus, a.bus, a.u.*dPdtet,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.bus, a.vbus,a.u.*dPdv,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.vbus,a.bus,a.u.*dQdtet,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.vbus,a.vbus,a.u.*dQdv,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.vref,a.vref,1,DAE.m,DAE.m);
