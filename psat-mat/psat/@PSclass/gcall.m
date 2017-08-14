function gcall(a)

global DAE

if ~a.n, return, end

type = a.con(:,2);
ty1 = find(type == 1);
ty2 = find(type == 2 | type == 4);
ty3 = find(type == 3 | type == 5);
tya = find(type > 1);
tyb = find(type > 3);

VSI = zeros(a.n,1);
SIw = find(a.con(:,3) == 1);
SIp = find(a.con(:,3) == 2);
SIv = find(a.con(:,3) == 3);
if SIw, VSI = DAE.x(a.omega(SIw)); end
if SIp, VSI = DAE.y(a.p(SIp)); end
if SIv, VSI = DAE.y(a.vbus(SIv)); end

T1 = a.con(:,8);
T2 = a.con(:,9);
T3 = a.con(:,10);
T4 = a.con(:,11);

Kw = a.con(:,6);
Kp = a.con(:,14);
Kv = a.con(:,15);

vsmax = a.con(:,4);
vsmin = a.con(:,5);
vathr = a.con(:,17);
v3max = a.con(:,18);
v3min = a.con(:,19);

S2 = a.con(:,22);
S2 = (((DAE.x(a.omega)-1) < 0) | S2) & S2 >= 0;

Vs = zeros(a.n,1);
if ty1
  Vs(ty1) = Kw(ty1).*DAE.x(a.omega(ty1)) + ...
       Kp(ty1).*DAE.y(a.p(ty1)) + ...
       Kv(ty1).*DAE.y(a.vbus(ty1)) + DAE.x(a.v1(ty1));
end
if tya
  y = (Kw+Kp+Kv).*VSI+DAE.x(a.v1);
end
if ty2
  A = T1(ty2)./T2(ty2);
  C = T3(ty2)./T4(ty2);
  Vs(ty2) = DAE.x(a.v3(ty2))+C.*(DAE.x(a.v2(ty2))+A.*y(ty2));
end
if ty3
  A = T1(ty3)./T2(ty3);
  B = 1-A;
  C = T3(ty3) - A.*T4(ty3);
  Vs(ty3) = A.*y(ty3) + C.*DAE.x(a.v3(ty3)) + B.*DAE.x(a.v2(ty3));
end
if tyb
  va = min(S2(tyb).*DAE.x(a.va(tyb)),vathr(tyb));
  va = max(va,0);
  Vs(tyb) = min(Vs(tyb),v3max(tyb));
  Vs(tyb) = max(Vs(tyb),v3min(tyb));
  Vs(tyb) = Vs(tyb)+va;
end
%Vs = round(Vs/Settings.dyntol)*Settings.dyntol;
Vs = max(Vs,vsmin);
Vs = min(Vs,vsmax);

DAE.g = DAE.g + sparse(a.vss,1,a.u.*(Vs-DAE.y(a.vss)),DAE.m,1);
DAE.g = DAE.g + sparse(a.vref,1,a.u.*DAE.y(a.vss),DAE.m,1);
