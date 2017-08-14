function Gycall(a)

global DAE

if ~a.n, return, end

V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);
a1 = DAE.y(a.bus1);
a2 = DAE.y(a.bus2);

vp = DAE.x(a.vp);
vq = DAE.x(a.vq);
iq = DAE.x(a.iq);

ss = sin(a1-a2+a.gamma);
cc = cos(a1-a2+a.gamma);

c1 = a.u.*a.y.*sqrt(vp.*vp+vq.*vq);
U = max(V1.^2+V2.^2-2.*V1.*V2.*cos(a1-a2),1e-6);

L0 = V1.*V2.*cos(a1-a2);
L1 = (U-V2.^2+L0)./U;
L2 = (U-V1.^2+L0)./U;
L5 = sin(a1-a2)./U;
L3 = -V2.*L5;
L4 =  V1.*L5;  

P1a1 =  c1.*L1.*V2.*cc;
P1a2 =  c1.*(L2-1).*V2.*cc;
P2a1 = -c1.*L1.*V2.*cc;  
P2a2 = -c1.*(L2-1).*V2.*cc;  
P1v1 =  c1.*L3.*V2.*cc;
P1v2 =  c1.*(ss+V2.*L4.*cc);
P2v1 = -c1.*L3.*V2.*cc;
P2v2 = -c1.*(ss+V2.*L4.*cc);  
Q1a1 = -c1.*(L1-1).*V1.*sin(a.gamma);
Q1a2 = -c1.*L2.*V1.*sin(a.gamma);
Q2a1 =  c1.*L1.*V2.*ss;
Q2a2 =  c1.*(L2-1).*V2.*ss;
Q1v1 =  c1.*(cos(a.gamma)-V1.*L3.*sin(a.gamma))-iq; 
Q1v2 = -c1.*L4.*V1.*sin(a.gamma);
Q2v1 =  c1.*L3.*V2.*ss;
Q2v2 = -c1.*(cc-V2.*L4.*ss);

ty2 = a.con(:,2) == 2 & a.u;
kp = ty2.*a.Cp./(1-a.Cp);
%Vq0 = a.Vq0 + ty2.*(kp.*V1.*sin(a1-a2)./ss - a.Vq0);
%U = max(V1.^2+V2.^2-2.*V1.*V2.*cos(a1-a2),1e-6);
F1 = kp.*V1.*V2.*sin(a1-a2)./U.^.5;
F3 = kp.*(V1-V2.*cos(a1-a2))./U.^.5;
F4 = kp.*(V2-V1.*cos(a1-a2))./U.^.5;     

DAE.Gy = DAE.Gy ...
          + sparse(a.bus1,a.bus1,P1a1,DAE.m,DAE.m) ...
          + sparse(a.bus1,a.bus2,P1a2,DAE.m,DAE.m) ...
          + sparse(a.bus2,a.bus1,P2a1,DAE.m,DAE.m) ...
          + sparse(a.bus2,a.bus2,P2a2,DAE.m,DAE.m);  

DAE.Gy = DAE.Gy ...
          + sparse(a.bus1,a.v1,P1v1,DAE.m,DAE.m) ...
          + sparse(a.bus1,a.v2,P1v2,DAE.m,DAE.m) ...
          + sparse(a.bus2,a.v1,P2v1,DAE.m,DAE.m) ...
          + sparse(a.bus2,a.v2,P2v2,DAE.m,DAE.m);  

DAE.Gy = DAE.Gy ...
          + sparse(a.v1,a.bus1,Q1a1,DAE.m,DAE.m) ...
          + sparse(a.v1,a.bus2,Q1a2,DAE.m,DAE.m) ...
          + sparse(a.v2,a.bus1,Q2a1,DAE.m,DAE.m) ...
          + sparse(a.v2,a.bus2,Q2a2,DAE.m,DAE.m);  

DAE.Gy = DAE.Gy ...
          + sparse(a.v1,a.v1,Q1v1,DAE.m,DAE.m) ...
          + sparse(a.v1,a.v2,Q1v2,DAE.m,DAE.m) ...
          + sparse(a.v2,a.v1,Q2v1,DAE.m,DAE.m) ...
          + sparse(a.v2,a.v2,Q2v2,DAE.m,DAE.m);

DAE.Gy = DAE.Gy ...
        - sparse(a.vp0,a.vp0,1,DAE.m,DAE.m) ...
        - sparse(a.vq0,a.vq0,1,DAE.m,DAE.m) ...
        - sparse(a.vref,a.vref,1,DAE.m,DAE.m);

DAE.Gy = DAE.Gy ...
         + sparse(a.vq0,a.bus1,F1,DAE.m,DAE.m) ...
         - sparse(a.vq0,a.bus2,F1,DAE.m,DAE.m) ...
         + sparse(a.vq0,a.v1,F3,DAE.m,DAE.m) ...
         + sparse(a.vq0,a.v2,F4,DAE.m,DAE.m);
