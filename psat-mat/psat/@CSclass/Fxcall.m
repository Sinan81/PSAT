function Fxcall(a)

global DAE Settings Wind

if ~a.n, return, end

Wn = 2*pi*Settings.freq;

notu = ~a.u;
omega_t = DAE.x(a.omega_t)+notu;
omega_m = DAE.x(a.omega_m);
gamma = DAE.x(a.gamma);
e1r = a.u.*DAE.x(a.e1r);
e1m = a.u.*DAE.x(a.e1m);

rho = getrho(Wind,a.wind);

V = a.u.*DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);
Vr = -V.*st;
Vm =  V.*ct;

r1 = a.con(:,6);
x0 = a.dat(:,1);
x1 = a.dat(:,2);
iT10 = a.u./a.dat(:,3);
i2Hwr = a.u.*a.dat(:,4);
i2Hm = a.u.*a.dat(:,5);
Ks = a.con(:,13);
R = a.dat(:,6);
A = a.dat(:,7);
ng = a.con(:,18);

k = r1.^2+x1.^2;
a13 = r1./k;
a23 = x1./k;
a33 = x0-x1;

Im = -a23.*(e1r-Vr)+a13.*(e1m-Vm);
Ir =  a13.*(e1r-Vr)+a23.*(e1m-Vm);

Vwrate = getvw(Wind,a.wind);
Vw = DAE.x(getidx(Wind,a.wind)).*Vwrate;
dPwdx = windpower(a,rho,Vw,A,R,omega_t,a.u,2)./Settings.mva/1e6;
Twr = ng.*windpower(a,rho,Vw,A,R,omega_t,a.u,1)./omega_t./Settings.mva/1e6;
slip = 1-omega_m;

IrV =  a13.*st-a23.*ct;
ImV = -a23.*st-a13.*ct;
Irt =  a13.*Vm-a23.*Vr;
Imt = -a23.*Vm-a13.*Vr;

DAE.Fx = DAE.Fx - sparse(a.omega_t,a.omega_t,notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_m,a.omega_m,notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.gamma,a.gamma,notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.e1r,a.e1r,notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.e1m,a.e1m,notu,DAE.n,DAE.n);

DAE.Fx = DAE.Fx - sparse(a.omega_t,a.gamma,Ks.*i2Hwr,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_m,a.gamma,Ks.*i2Hm,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.gamma,a.omega_t,Wn*a.u,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.gamma,a.omega_m,Wn*a.u,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.omega_t,a.omega_t,(ng.*dPwdx(:,1)-Twr).*i2Hwr./omega_t,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_t,getidx(Wind,a.wind),Vwrate.*ng.*dPwdx(:,2).*i2Hwr./omega_t,DAE.n,DAE.n);

DAE.Fx = DAE.Fx - sparse(a.omega_m,a.e1r,(Ir+e1r.*a13-e1m.*a23).*i2Hm,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_m,a.e1m,(Im+e1r.*a23+e1m.*a13).*i2Hm,DAE.n,DAE.n);

DAE.Fx = DAE.Fx - sparse(a.e1r,a.omega_m,Wn*e1m,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.e1r,a.e1r,(1+a33.*a23).*iT10,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.e1r,a.e1m,Wn*a.u.*slip+a33.*a13.*iT10,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.e1m,a.omega_m,Wn*e1r,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.e1m,a.e1r,Wn*a.u.*slip+a33.*a13.*iT10,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.e1m,a.e1m,(1+a33.*a23).*iT10,DAE.n,DAE.n);

DAE.Gx = DAE.Gx - sparse(a.bus,a.e1r,a13.*Vr-a23.*Vm,DAE.m,DAE.n);
DAE.Gx = DAE.Gx - sparse(a.bus,a.e1m,a23.*Vr+a13.*Vm,DAE.m,DAE.n);
DAE.Gx = DAE.Gx - sparse(a.vbus,a.e1r,a23.*Vr+a13.*Vm,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.vbus,a.e1m,a13.*Vr-a23.*Vm,DAE.m,DAE.n);

DAE.Fy = DAE.Fy - sparse(a.omega_m,a.bus,(e1r.*Irt+e1m.*Imt).*i2Hm,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.e1r,a.bus,a33.*Imt.*iT10,DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(a.e1m,a.bus,a33.*Irt.*iT10,DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(a.omega_m,a.vbus,(e1r.*IrV+e1m.*ImV).*i2Hm,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.e1r,a.vbus,a33.*ImV.*iT10,DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(a.e1m,a.vbus,a33.*IrV.*iT10,DAE.n,DAE.m);
