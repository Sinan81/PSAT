function gcall(a)

global DAE

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

V = getstatus(a).*DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);
Vr = V.*st;
Vm = V.*ct;
r1 = a.con(:,7);
rr = a.con(:,9);
x0 = a.dat(:,5);
x1 = a.dat(:,6);
x2 = a.dat(:,7);
ixm = a.dat(:,10);
x1s = a.dat(:,11);

if im1
  bm1 = a.bus(im1);
  vm1 = a.vbus(im1);
  a11 = rr(im1).*rr(im1) + slip(im1).*slip(im1).*(x1s(im1).* ...
        x1s(im1)+r1(im1).*r1(im1)) + 2*slip(im1).*r1(im1).*rr(im1);
  DAE.g = DAE.g + sparse(bm1,1,rr(im1).*V(im1).*V(im1).*slip(im1)./a11,DAE.m,1);
  DAE.g = DAE.g + sparse(vm1,1,V(im1).*V(im1).*(ixm(im1)+(x1s(im1).*slip(im1).*slip(im1)./a11)),DAE.m,1);
end

if im3
  bm3 = a.bus(im3);
  vm3 = a.vbus(im3);
  e1r(im3) = DAE.x(a.e1r(im3));
  e1m(im3) = DAE.x(a.e1m(im3));
  a03 = r1(im3).^2+x1(im3).^2;
  a13 = r1(im3)./a03;
  a23 = x1(im3)./a03;
  a33 = x0(im3)-x1(im3);
  Im = -a23.*(-Vr(im3)-e1r(im3))+a13.*(Vm(im3)-e1m(im3));
  Ir =  a13.*(-Vr(im3)-e1r(im3))+a23.*(Vm(im3)-e1m(im3));
  DAE.g = DAE.g + sparse(bm3,1,-Vr(im3).*Ir+Vm(im3).*Im,DAE.m,1);
  DAE.g = DAE.g + sparse(vm3,1, Vr(im3).*Im+Vm(im3).*Ir,DAE.m,1);
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
  a35 = x0(im5)-x1(im5);
  a45 = x1(im5)-x2(im5);
  Ir =  a15.*(-Vr(im5)-e2r(im5))+a25.*(Vm(im5)-e2m(im5));
  Im = -a25.*(-Vr(im5)-e2r(im5))+a15.*(Vm(im5)-e2m(im5));
  DAE.g = DAE.g + sparse(bm5,1,-Vr(im5).*Ir+Vm(im5).*Im,DAE.m,1);
  DAE.g = DAE.g + sparse(vm5,1, Vr(im5).*Im+Vm(im5).*Ir,DAE.m,1);
end
