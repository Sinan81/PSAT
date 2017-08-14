function Fxcall(a)

global DAE

if ~a.n, return, end

V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);
t1 = DAE.y(a.bus1);
t2 = DAE.y(a.bus2);
ss = sin(t1-t2);
cc = cos(t1-t2);
Tr = a.con(:,9);

x1 = DAE.x(a.x1);
x1_max = a.con(:,10);
x1_min = a.con(:,11);

DB = dbtcsc(a);

u = x1 < x1_max & x1 > x1_min & a.u;
tx = a.con(:,3) == 1;
t2 = a.con(:,3) == 2 & a.u;
ta = a.con(:,4) == 1;   

Kp = t2.*a.con(:,12);
Ki = t2.*a.con(:,13);

DAE.Fx = DAE.Fx - sparse(a.x1,a.x1,1./Tr,DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(a.x1,a.x0,a.u./Tr,DAE.n,DAE.m);

P1vs = DB.*V1.*V2.*ss;  
Q1vs = DB.*V1.*(V1-V2.*cc);
Q2vs = DB.*V2.*(V2-V1.*cc);

DAE.Gx = DAE.Gx + sparse(a.bus1,a.x1,u.*P1vs,DAE.m,DAE.n);  
DAE.Gx = DAE.Gx - sparse(a.bus2,a.x1,u.*P1vs,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.v1,a.x1,u.*Q1vs,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.v2,a.x1,u.*Q2vs,DAE.m,DAE.n);    
DAE.Gx = DAE.Gx - sparse(a.x0,a.x1,u.*ta.*Kp.*P1vs,DAE.m,DAE.n);

a1 = ta.*ss.*(a.B+a.y);
a3 = V1.*V2;
a5 = ta.*a3.*cc.*(a.B+a.y);
i2 = find(t2);
x2 = a.x2(i2);

ty2 = find(a.con(:,3) == 2);

DAE.Fx = DAE.Fx - sparse(a.x2(ty2),a.x2(ty2),~a.u(ty2),DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(x2,a.pref(i2),Ki(i2),DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(x2,a.v1(i2),Ki(i2).*V2(i2).*a1(i2),DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(x2,a.v2(i2),Ki(i2).*V1(i2).*a1(i2),DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(x2,a.bus1(i2),Ki(i2).*a5(i2),DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(x2,a.bus2(i2),Ki(i2).*a5(i2),DAE.n,DAE.m);
DAE.Fx = DAE.Fx - sparse(x2,a.x1(i2),u(i2).*ta(i2).*Ki(i2).*P1vs(i2),DAE.n,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.x0(i2),x2,t2(i2),DAE.m,DAE.n);
