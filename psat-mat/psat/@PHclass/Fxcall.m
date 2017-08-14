function Fxcall(p)

global DAE

if ~p.n, return, end

alpha = DAE.x(p.alpha);
V1 = p.u.*DAE.y(p.v1);
V2 = p.u.*DAE.y(p.v2);

Tm = p.con(:,7);
Kp = p.con(:,8);
Ki = p.con(:,9);
Pref = p.con(:,10);

a_max = p.con(:,13);
a_min = p.con(:,14);

V12 = V1.*V2;
y = admittance(p);
g = real(y);
b = imag(y);
m = p.con(:,15);

[s12,c12] = angles(p);

k1 = (c12.*g+s12.*b)./m;
k2 = (c12.*g-s12.*b)./m;
k3 = (s12.*g-c12.*b)./m;
k4 = (s12.*g+c12.*b)./m;

b1 = 2.*V1.*g./m./m-V2.*k1;
b2 = V1.*k1;

k1 = V12.*k1;
k2 = V12.*k2;
k3 = V12.*k3;
k4 = V12.*k4;

idx = find(alpha < a_max & alpha > a_min & p.u);
if ~isempty(idx)
  
  ai  = p.alpha(idx);
  b1i = p.bus1(idx);
  b2i = p.bus2(idx);
  v1i = p.v1(idx);
  v2i = p.v2(idx);
  pmi = p.Pm(idx);
  
  DAE.Fx = DAE.Fx - sparse(ai,pmi,Kp(idx)./Tm(idx)-Ki(idx),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(pmi,ai,k3(idx)./Tm(idx),DAE.n,DAE.n);
  
  DAE.Fy = DAE.Fy + sparse(ai,v1i,Kp(idx).*b1(idx)./Tm(idx),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(ai,v2i,Kp(idx).*b2(idx)./Tm(idx),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(ai,b1i,Kp(idx).*k3(idx)./Tm(idx),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(ai,b2i,Kp(idx).*k3(idx)./Tm(idx),DAE.n,DAE.m);
  
  DAE.Gx = DAE.Gx - sparse(b1i,ai,k3(idx),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(v1i,ai,k1(idx),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(b2i,ai,k4(idx),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(v2i,ai,k2(idx),DAE.m,DAE.n);
  
end

DAE.Fx = DAE.Fx - sparse(p.alpha,p.alpha,(Kp.*k3+(~p.u))./Tm,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(p.Pm,p.Pm,1./Tm,DAE.n,DAE.n);

DAE.Fy = DAE.Fy + sparse(p.Pm,p.v1,b1./Tm,DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(p.Pm,p.v2,b2./Tm,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(p.Pm,p.bus1,k3./Tm,DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(p.Pm,p.bus2,k3./Tm,DAE.n,DAE.m);
