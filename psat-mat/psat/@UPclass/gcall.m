function a = gcall(a)

global DAE

if ~a.n, return, end

V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);
a1 = DAE.y(a.bus1);
a2 = DAE.y(a.bus2);

vp = DAE.x(a.vp);
vq = DAE.x(a.vq);
iq = DAE.x(a.iq);

a.gamma = fgamma(a);
ss = sin(a1-a2+a.gamma);
cc = cos(a1-a2+a.gamma);

c1 = a.u.*a.y.*sqrt(vp.*vp+vq.*vq);

P1 =  c1.*V2.*ss;
Q1 =  c1.*V1.*cos(a.gamma)-iq.*V1;
Q2 = -c1.*V2.*cc;
  
ty2 = a.con(:,2) == 2;
kp = a.Cp./(1-a.Cp);
Vq0 = a.Vq0 + ty2.*(kp.*V1.*sin(a1-a2)./ss - a.Vq0);

DAE.g = DAE.g ...
        + sparse(a.bus1,1,P1,DAE.m,1) ...
        - sparse(a.bus2,1,P1,DAE.m,1) ...
        + sparse(a.v1,1,Q1,DAE.m,1) ...
        + sparse(a.v2,1,Q2,DAE.m,1); 

DAE.g = DAE.g ...
        + sparse(a.vp0,1,a.Vp0-DAE.y(a.vp0),DAE.m,1) ...
        + sparse(a.vq0,1,Vq0-DAE.y(a.vq0),DAE.m,1) ...
        + sparse(a.vref,1,a.Vref-DAE.y(a.vref),DAE.m,1);
