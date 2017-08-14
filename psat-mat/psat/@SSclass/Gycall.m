function Gycall(a)

global DAE

if ~a.n, return, end

V1 = a.u.*DAE.y(a.v1);
V2 = a.u.*DAE.y(a.v2);
a1 = DAE.y(a.bus1);
a2 = DAE.y(a.bus2);
ss = sin(a1-a2);
cc = cos(a1-a2);
Kpr = a.con(:,11);

den = ssscden(a);
c1 = DAE.x(a.vcs).*a.y./den;
c2 = DAE.x(a.vcs).*a.y./(den.^3);  
M2 = c2.*V1.*V2.*ss;  
M1 = -M2;
M3 = c2.*(V2.*cc-V1);
M4 = c2.*(V1.*cc-V2);

P1a1 = V1.*V2.*(M1.*ss+c1.*cc);
P1a2 = V1.*V2.*(M2.*ss-c1.*cc);
P1v1 = V2.*ss.*(M3.*V1+c1);
P1v2 = V1.*ss.*(M4.*V2+c1);

Q1a1 = -V1.*V2.*(M1.*cc-c1.*ss)+M1.*V1.^2;
Q1a2 = -V1.*V2.*(M2.*cc+c1.*ss)+M2.*V1.^2;
Q2a1 = -V1.*V2.*(M1.*cc-c1.*ss)+M1.*V2.^2;  
Q2a2 = -V1.*V2.*(M2.*cc+c1.*ss)+M2.*V2.^2;  

Q1v1 = M3.*V1.*(V1-V2.*cc)+c1.*(2.*V1-V2.*cc);
Q1v2 = M4.*V1.*(V1-V2.*cc)-c1.*V1.*cc;
Q2v1 = M3.*V2.*(V2-V1.*cc)-c1.*V2.*cc;
Q2v2 = M4.*V2.*(V2-V1.*cc)+c1.*(2.*V2-V1.*cc);

DAE.Gy = DAE.Gy ...
          + sparse(a.bus1,a.bus1,P1a1,DAE.m,DAE.m) ...
          + sparse(a.bus1,a.bus2,P1a2,DAE.m,DAE.m) ...
          - sparse(a.bus2,a.bus1,P1a1,DAE.m,DAE.m) ...
          - sparse(a.bus2,a.bus2,P1a2,DAE.m,DAE.m);

DAE.Gy = DAE.Gy ...
          + sparse(a.bus1,a.v1,P1v1,DAE.m,DAE.m) ...
          + sparse(a.bus1,a.v2,P1v2,DAE.m,DAE.m) ...
          - sparse(a.bus2,a.v1,P1v1,DAE.m,DAE.m) ...
          - sparse(a.bus2,a.v2,P1v2,DAE.m,DAE.m);  

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
          - sparse(a.v0,a.v0,1,DAE.m,DAE.m) ...
          - sparse(a.pref,a.pref,1,DAE.m,DAE.m);

ty2 = a.con(:,2) == 2;
ty3 = a.con(:,2) == 3;

h = find(a.u.*ty2);
if h
  kp = a.Cp./(1-a.Cp);
  k = kp(h)./den(h);
  F1 = k.*(V1(h).*V2(h).*ss(h));   
  F3 = k.*(V1(h)-V2(h).*cc(h));
  F4 = k.*(V2(h)-V1(h).*cc(h));     
  DAE.Gy = DAE.Gy + sparse(a.v0(h),a.bus1(h),F1,DAE.m,DAE.m);
  DAE.Gy = DAE.Gy - sparse(a.v0(h),a.bus2(h),F1,DAE.m,DAE.m);
  DAE.Gy = DAE.Gy + sparse(a.v0(h),a.v1(h),F3,DAE.m,DAE.m);
  DAE.Gy = DAE.Gy + sparse(a.v0(h),a.v2(h),F4,DAE.m,DAE.m);
end

h = find(a.u.*ty3);
if h
  
  c = find(a.con(h,10) ~= 2);
  b = h(c);
  vcs = DAE.x(a.vcs);
  c1 = a.y(h).*(1+vcs(h)./den(h));
  c2 = a.y(h).*vcs(h)./(den(h).^3);    
  Ms = a.y(h)./den(h);
  M2 = c2.*V1(h).*V2(h).*ss(h);
  M1 = -M2;
  M3 = c2.*(V2(h).*cc(h)-V1(h));
  M4 = c2.*(V1(h).*cc(h)-V2(h));              
  Jps1 = V1(h).*V2(h).*(M1.*ss(h)+c1.*cc(h));
  Jps2 = V1(h).*V2(h).*(M2.*ss(h)-c1.*cc(h));
  Jps3 = V2(h).*ss(h).*(M3.*V1(h)+c1);
  Jps4 = V1(h).*ss(h).*(M4.*V2(h)+c1);

  DAE.Gy = DAE.Gy + sparse(a.v0(h),a.pref(h),Kpr(h),DAE.m,DAE.m);
  DAE.Gy = DAE.Gy - sparse(a.v0(b),a.bus1(b),Jps1(c).*Kpr(b),DAE.m,DAE.m);
  DAE.Gy = DAE.Gy - sparse(a.v0(b),a.bus2(b),Jps2(c).*Kpr(b),DAE.m,DAE.m);
  DAE.Gy = DAE.Gy - sparse(a.v0(b),a.v1(b),Jps3(c).*Kpr(b),DAE.m,DAE.m);
  DAE.Gy = DAE.Gy - sparse(a.v0(b),a.v2(b),Jps4(c).*Kpr(b),DAE.m,DAE.m);
  
end    
