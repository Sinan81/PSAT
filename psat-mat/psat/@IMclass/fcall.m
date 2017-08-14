function fcall(a)

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
i2Hm = u.*a.dat(:,4);
x0 = a.dat(:,5);
x1 = a.dat(:,6);
x2 = a.dat(:,7);
T10 = a.dat(:,8);
T20 = a.dat(:,9);
ixm = a.dat(:,10);
x1s = a.dat(:,11);
Tm = DAE.lambda*(A + slip.*(B + slip.*C));

if im1
  a11 = rr(im1).*rr(im1) + slip(im1).*slip(im1).*(x1s(im1).*x1s(im1)+r1(im1).*r1(im1)) + 2*slip(im1).*r1(im1).*rr(im1);
  DAE.f(a.slip(im1)) = (Tm(im1)-rr(im1).*V(im1).*V(im1).*slip(im1)./a11).*i2Hm(im1);
end

if im3
  e1r(im3) = DAE.x(a.e1r(im3));
  e1m(im3) = DAE.x(a.e1m(im3));
  a03 = r1(im3).^2+x1(im3).^2;
  a13 = r1(im3)./a03;
  a23 = x1(im3)./a03;
  a33 = x0(im3)-x1(im3);
  Im = -a23.*(-Vr(im3)-e1r(im3))+a13.*(Vm(im3)-e1m(im3));
  Ir =  a13.*(-Vr(im3)-e1r(im3))+a23.*(Vm(im3)-e1m(im3));
  DAE.f(a.slip(im3)) = (Tm(im3)-e1r(im3).*Ir-e1m(im3).*Im).*i2Hm(im3);
  DAE.f(a.e1r(im3)) =  Wn(im3).*slip(im3).*e1m(im3)-(e1r(im3)+a33.*Im)./T10(im3);
  DAE.f(a.e1m(im3)) = -Wn(im3).*slip(im3).*e1r(im3)-(e1m(im3)-a33.*Ir)./T10(im3);
end

if im5
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
  DAE.f(a.slip(im5)) = (Tm(im5)-e2r(im5).*Ir-e2m(im5).*Im).*i2Hm(im5);
  DAE.f(a.e1r(im5))  =  Wn(im5).*slip(im5).*e1m(im5)-(e1r(im5)+a35.*Im)./T10(im5);
  DAE.f(a.e1m(im5))  = -Wn(im5).*slip(im5).*e1r(im5)-(e1m(im5)-a35.*Ir)./T10(im5);
  DAE.f(a.e2r(im5))  = -Wn(im5).*slip(im5).*(e1m(im5)-e2m(im5))+DAE.f(a.e1r(im5))+(e1r(im5)-e2r(im5)-a45.*Im)./T20(im5);
  DAE.f(a.e2m(im5))  =  Wn(im5).*slip(im5).*(e1r(im5)-e2r(im5))+DAE.f(a.e1m(im5))+(e1m(im5)-e2m(im5)+a45.*Ir)./T20(im5);
end

% non-windup limit (the motor cannot work as a brake)
idx = find(slip >= 1 & ~a.con(:,19) & DAE.f(a.slip) > 0);
if idx
  DAE.f(a.slip(idx)) = 0; 
  DAE.x(a.slip) = min(slip,1);
end
