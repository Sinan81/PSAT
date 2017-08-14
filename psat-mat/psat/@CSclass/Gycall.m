function Gycall(a)

global DAE

if ~a.n, return, end

e1r = a.u.*DAE.x(a.e1r);
e1m = a.u.*DAE.x(a.e1m);

V = a.u.*DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);
Vr = -V.*st;
Vm =  V.*ct;

r1 = a.con(:,6);
x0 = a.dat(:,1);
x1 = a.dat(:,2);

B = a.dat(:,8);

k = r1.^2+x1.^2;
a13 = r1./k;
a23 = x1./k;
a33 = x0-x1;

Im = -a23.*(e1r-Vr)+a13.*(e1m-Vm);
Ir =  a13.*(e1r-Vr)+a23.*(e1m-Vm);

Pv = -Ir.*st + Im.*ct;
Pt = -Ir.*Vm + Im.*Vr;
Qv =  Ir.*ct + Im.*st;
Qt =  Ir.*Vr + Im.*Vm;

IrV =  a13.*st-a23.*ct;
ImV = -a23.*st-a13.*ct;
Irt =  a13.*Vm-a23.*Vr;
Imt = -a23.*Vm-a13.*Vr;

DAE.Gy = DAE.Gy - sparse(a.bus,a.bus,Pt+Vr.*Irt+Vm.*Imt,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.bus,a.vbus,Pv+Vr.*IrV+Vm.*ImV,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.vbus,a.bus,Qt+Vm.*Irt-Vr.*Imt,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.vbus,a.vbus,Qv+Vm.*IrV-Vr.*ImV+2*B.*V,DAE.m,DAE.m);
