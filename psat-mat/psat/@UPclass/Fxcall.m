function Fxcall(a)

global DAE

if ~a.n, return, end

V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);
a1 = DAE.y(a.bus1);
a2 = DAE.y(a.bus2);

vp = DAE.x(a.vp);
vq = DAE.x(a.vq);
iq = DAE.x(a.iq);

Kr = a.con(:,7);
Tr = a.con(:,8);
kp = a.Cp./(1-a.Cp);
ty2 = a.con(:,2) == 2;

ss = sin(a1-a2+a.gamma);
cc = cos(a1-a2+a.gamma);

vs = max(sqrt(vp.*vp+vq.*vq),1e-6);
k1 = kp.*V1.*sin(a1-a2).*cc./vs./ss./ss./vs;
c1 = a.y.*V1;
c2 = a.y.*vs;

P1r =  c1.*V2.*ss;
P2r = -c1.*V2.*ss;
Q1r =  c1.*V1.*cos(a.gamma);
Q2r = -c1.*V2.*cc;

P1a =  c2.*V2.*cc;
P2a = -c2.*V2.*cc;
Q1a = -c2.*V1.*sin(a.gamma);  
Q2a =  c2.*V2.*ss;  

P1vp = P1r.*vp./(V1.*vs) - P1a.*vq./vs.^2;
P2vp = P2r.*vp./(V1.*vs) - P2a.*vq./vs.^2;
Q1vp = Q1r.*vp./(V1.*vs) - Q1a.*vq./vs.^2;
Q2vp = Q2r.*vp./(V1.*vs) - Q2a.*vq./vs.^2;  

P1vq = P1r.*vq./(V1.*vs) + P1a.*vp./vs.^2;
P2vq = P2r.*vq./(V1.*vs) + P2a.*vp./vs.^2;
Q1vq = Q1r.*vq./(V1.*vs) + Q1a.*vp./vs.^2;
Q2vq = Q2r.*vq./(V1.*vs) + Q2a.*vp./vs.^2;

DAE.Fx = DAE.Fx - sparse(a.vp,a.vp,a.u./Tr,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.vq,a.vq,a.u./Tr,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.iq,a.iq,a.u./Tr,DAE.n,DAE.n);

DAE.Fy = DAE.Fy + sparse(a.vp,a.vp0,a.u./Tr,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.vq,a.vq0,a.u./Tr,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.iq,a.vref,a.u.*Kr./Tr,DAE.n,DAE.m);

ap = vp < a.con(:,9)  & vp > a.con(:,10) & a.u;
aq = vq < a.con(:,11) & vq > a.con(:,12) & a.u;
ac = iq < a.con(:,13) & iq > a.con(:,14) & a.u;

DAE.Gx = DAE.Gx + sparse(a.bus1,a.vp,ap.*P1vp,DAE.m,DAE.n);  
DAE.Gx = DAE.Gx + sparse(a.bus2,a.vp,ap.*P2vp,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.v1,a.vp,ap.*Q1vp,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.v2,a.vp,ap.*Q2vp,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.vq0,a.vp,ty2.*ap.*k1.*vq,DAE.m,DAE.n);
DAE.Gx = DAE.Gx - sparse(a.vq0,a.vq,ty2.*aq.*k1.*vp,DAE.m,DAE.n);

DAE.Gx = DAE.Gx + sparse(a.bus1,a.vq,aq.*P1vq,DAE.m,DAE.n);  
DAE.Gx = DAE.Gx + sparse(a.bus2,a.vq,aq.*P2vq,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.v1,a.vq,aq.*Q1vq,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.v2,a.vq,aq.*Q2vq,DAE.m,DAE.n); 

DAE.Gx = DAE.Gx - sparse(a.v1,a.iq,ac.*V1,DAE.m,DAE.n);
DAE.Fy = DAE.Fy - sparse(a.iq,a.v1,ac.*Kr./Tr,DAE.n,DAE.m);
