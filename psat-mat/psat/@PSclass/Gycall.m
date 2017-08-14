function Gycall(a)

global DAE

if ~a.n, return, end

type = a.con(:,2);
ty1 = find(type == 1);
ty2 = find(type == 2 | type == 4);
ty3 = find(type == 3 | type == 5);

T1 = a.con(:,8);
T2 = a.con(:,9);
T3 = a.con(:,10);
T4 = a.con(:,11);

Kp = a.con(:,14);
Kv = a.con(:,15);

vsmax = a.con(:,4);
vsmin = a.con(:,5);

vss = DAE.y(a.vss);
z = vss < vsmax & vss > vsmin & a.u;
DAE.Gy = DAE.Gy - sparse(a.vss,a.vss,1,DAE.m,DAE.m);
DAE.Gy = DAE.Gy + sparse(a.vref,a.vss,z,DAE.m,DAE.m);

if ty1
  DAE.Gy = DAE.Gy ...
           + sparse(a.vss(ty1),a.vbus(ty1),z(ty1).*Kv(ty1),DAE.m,DAE.m) ...
           + sparse(a.vss(ty1),a.p(ty1),z(ty1).*Kp(ty1),DAE.m,DAE.m);
end

if ty2
  A = T1(ty2)./T2(ty2);
  C = T3(ty2)./T4(ty2);
  E = C.*A;
  DAE.Gy = DAE.Gy ...
           + sparse(a.vss(ty2),a.vbus(ty2),z(ty2).*Kv(ty2).*E,DAE.m,DAE.m) ...
           + sparse(a.vss(ty2),a.p(ty2),z(ty2).*Kp(ty2).*E,DAE.m,DAE.m);
end

if ty3
  A = T1(ty3)./T2(ty3);
  DAE.Gy = DAE.Gy ...
           + sparse(a.vss(ty3),a.vbus(ty3),z(ty3).*Kv(ty3).*A,DAE.m,DAE.m) ...
           + sparse(a.vss(ty3),a.p(ty3),z(ty3).*Kp(ty3).*A,DAE.m,DAE.m);
end
