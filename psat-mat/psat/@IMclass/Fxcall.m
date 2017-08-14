function Fxcall(a)

global DAE Settings

if ~a.n, return, end

ord = a.con(:,5);

im1 = find(ord == 1);
im3 = find(ord == 3);
im5 = find(ord == 5);

slip = DAE.x(a.slip);
e1r = zeros(a.n,1);
e1m = zeros(a.n,1);
e2r = zeros(a.n,1);
e2m = zeros(a.n,1);

u = getstatus(a);
z = slip < 1 | a.con(:,19);
Wn = 2*pi*Settings.freq*u;
V = u.*DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);
Vr = V.*st;
Vm = V.*ct;
r1 = a.con(:,7);
rr = a.con(:,9);
A = a.dat(:,1);
B = a.dat(:,2);
C = a.dat(:,3);
i2Hm = z.*u.*a.dat(:,4);
x0 = a.dat(:,5);
x1 = a.dat(:,6);
x2 = a.dat(:,7);
T10 = a.dat(:,8);
T20 = a.dat(:,9);
ixm = a.dat(:,10);
x1s = a.dat(:,11);
km = DAE.lambda*(B+2*C.*slip);

if im1
  
  bm1 = a.bus(im1);
  vm1 = a.vbus(im1);
  v2 = V(im1).*V(im1);
  s2 = slip(im1).*slip(im1);
  z2 = x1s(im1).*x1s(im1)+r1(im1).*r1(im1); 
  rsr = r1(im1).*rr(im1);
  
  a11 = rr(im1).*rr(im1) + s2.*z2 + 2*slip(im1).*rsr;

  is1 = a.slip(im1);
  a21 = a11.*a11;
  a31 = 2*(slip(im1).*z2 + rsr);
  ks = v2.*rr(im1).*(a11-slip(im1).*a31)./a21;

  DAE.Fx = DAE.Fx + sparse(is1,is1,(km(im1)-ks).*i2Hm(im1)-(~u(im1)),DAE.n,DAE.n);
  DAE.Fy = DAE.Fy + sparse(is1,vm1,-2*rr(im1).*V(im1).*slip(im1).*i2Hm(im1)./a11,DAE.n,DAE.m);

  DAE.Gx = DAE.Gx + sparse(bm1,is1,z(im1).*ks,DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(vm1,is1,z(im1).*v2.*x1s(im1).*(2*slip(im1).*a11-s2.*a31)./a21,DAE.m,DAE.n);

end

if im3
  
  bm3 = a.bus(im3);
  vm3 = a.vbus(im3);

  e1r(im3) = DAE.x(a.e1r(im3));
  e1m(im3) = DAE.x(a.e1m(im3));

  a03 = r1(im3).^2+x1(im3).^2;
  a13 = r1(im3)./a03;
  a23 = x1(im3)./a03;
  a33 = u(im3).*(x0(im3)-x1(im3));

  is3 = a.slip(im3);
  er3 = a.e1r(im3);
  em3 = a.e1m(im3);
  Im = -a23.*(-Vr(im3)-e1r(im3))+a13.*(Vm(im3)-e1m(im3));
  Ir =  a13.*(-Vr(im3)-e1r(im3))+a23.*(Vm(im3)-e1m(im3));
  Am =  a23.*Vm(im3)-a13.*Vr(im3);
  Ar = -a13.*Vm(im3)-a23.*Vr(im3);
  Bm =  a23.*st(im3)+a13.*ct(im3);
  Br = -a13.*st(im3)+a23.*ct(im3);
  
  DAE.Fx = DAE.Fx + sparse(is3,is3, km(im3).*i2Hm(im3)-(~u(im3)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(is3,er3, (-Ir+e1r(im3).*a13-e1m(im3).*a23).*i2Hm(im3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(is3,em3, (e1r(im3).*a23-Im+e1m(im3).*a13).*i2Hm(im3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(er3,is3, z(im3).*Wn(im3).*e1m(im3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(er3,er3, (1+a33.*a23)./T10(im3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(er3,em3, Wn(im3).*slip(im3)+a33.*a13./T10(im3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em3,is3, z(im3).*Wn(im3).*e1r(im3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em3,er3, Wn(im3).*slip(im3)+a33.*a13./T10(im3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em3,em3, (1+a33.*a23)./T10(im3),DAE.n,DAE.n);
  
  DAE.Gx = DAE.Gx + sparse(bm3,er3, a13.*Vr(im3)+a23.*Vm(im3),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(bm3,em3, a23.*Vr(im3)-a13.*Vm(im3),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(vm3,er3, a23.*Vr(im3)-a13.*Vm(im3),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(vm3,em3, a13.*Vr(im3)+a23.*Vm(im3),DAE.m,DAE.n);
  
  DAE.Fy = DAE.Fy - sparse(is3,bm3, (e1r(im3).*Ar+e1m(im3).*Am).*i2Hm(im3),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(er3,bm3, a33.*Am./T10(im3),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(em3,bm3, a33.*Ar./T10(im3),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(is3,vm3, (e1r(im3).*Br+e1m(im3).*Bm).*i2Hm(im3),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(er3,vm3, a33.*Bm./T10(im3),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(em3,vm3, a33.*Br./T10(im3),DAE.n,DAE.m);
  
end

if im5
  
  bm5 = a.bus(im5);
  vm5 = a.vbus(im5);

  e1r(im5) = DAE.x(a.e1r(im5));
  e1m(im5) = DAE.x(a.e1m(im5));
  e2r(im5) = DAE.x(a.e2r(im5));
  e2m(im5) = DAE.x(a.e2m(im5));

  a05 = r1(im5).^2+x2(im5).^2;
  a15 = r1(im5)./a05;
  a25 = x2(im5)./a05;
  a35 = u(im5).*(x0(im5)-x1(im5));
  a45 = u(im5).*(x1(im5)-x2(im5));

  is5 = a.slip(im5);
  er1 = a.e1r(im5);
  em1 = a.e1m(im5);
  er2 = a.e2r(im5);
  em2 = a.e2m(im5);
  
  Ir =  a15.*(-Vr(im5)-e2r(im5))+a25.*(Vm(im5)-e2m(im5));
  Im = -a25.*(-Vr(im5)-e2r(im5))+a15.*(Vm(im5)-e2m(im5));
  Ar = -a15.*Vm(im5)-a25.*Vr(im5);
  Am =  a25.*Vm(im5)-a15.*Vr(im5);
  Br = -a15.*st(im5)+a25.*ct(im5);
  Bm =  a25.*st(im5)+a15.*ct(im5);
  
  DAE.Fx = DAE.Fx + sparse(is5,is5, km(im5).*i2Hm(im5)-(~u(im5)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(is5,er2, (-Ir+e2r(im5).*a15-e2m(im5).*a25).*i2Hm(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(is5,em2, (e2r(im5).*a25-Im+e2m(im5).*a15).*i2Hm(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(er1,is5, z(im5).*Wn(im5).*e1m(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(er1,er1, 1./T10(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(er1,em1, Wn(im5).*slip(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(er1,er2, a35.*a25./T10(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(er1,em2, a35.*a15./T10(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em1,is5, z(im5).*Wn(im5).*e1r(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em1,er1, Wn(im5).*slip(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em1,em1, 1./T10(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em1,er2, a35.*a15./T10(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em1,em2, a35.*a25./T10(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(er2,is5, z(im5).*Wn(im5).*e2m(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(er2,er1, u(im5)./T20(im5)-u(im5)./T10(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(er2,er2, a35.*a25./T10(im5)+(1+a45.*a25)./T20(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(er2,em2, Wn(im5).*slip(im5)+a35.*a15./T10(im5)+a45.*a15./T20(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em2,is5, z(im5).*Wn(im5).*e2r(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(em2,em1, u(im5)./T20(im5)-u(im5)./T10(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em2,er2, Wn(im5).*slip(im5)+a35.*a15./T10(im5)+a45.*a15./T20(im5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(em2,em2, a35.*a25./T10(im5)+(1+a45.*a25)./T20(im5),DAE.n,DAE.n);
  
  DAE.Gx = DAE.Gx + sparse(bm5,er2, a15.*Vr(im5)+a25.*Vm(im5),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(bm5,em2, a25.*Vr(im5)-a15.*Vm(im5),DAE.m,DAE.n);
  
  DAE.Gx = DAE.Gx + sparse(vm5,er2, a25.*Vr(im5)-a15.*Vm(im5),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(vm5,em2, a15.*Vr(im5)+a25.*Vm(im5),DAE.m,DAE.n);
  
  DAE.Fy = DAE.Fy - sparse(is5,bm5, (e2r(im5).*Ar+e2m(im5).*Am).*i2Hm(im5),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(er1,bm5, a35.*Am./T10(im5),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(em1,bm5, a35.*Ar./T10(im5),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(er2,bm5, a35.*Am./T10(im5)+a45.*Am./T20(im5),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(em2,bm5, a35.*Ar./T10(im5)+a45.*Ar./T20(im5),DAE.n,DAE.m);
  
  DAE.Fy = DAE.Fy - sparse(is5,vm5, (e2r(im5).*Br+e2m(im5).*Bm).*i2Hm(im5),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(er1,vm5, a35.*Bm./T10(im5),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(em1,vm5, a35.*Br./T10(im5),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(er2,vm5, a35.*Bm./T10(im5)+a45.*Bm./T20(im5),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(em2,vm5, a35.*Br./T10(im5)+a45.*Br./T20(im5),DAE.n,DAE.m);
    
end

