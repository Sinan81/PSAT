function a = fcall(a)

global DAE Syn

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

Tw = a.con(:,7);
T1 = a.con(:,8);
T2 = a.con(:,9);
T3 = a.con(:,10);
T4 = a.con(:,11);
Ta = a.con(:,13);

Kw = a.con(:,6);
Ka = a.con(:,12);
Kp = a.con(:,14);
Kv = a.con(:,15);

ETHR = a.con(:,20);
WTHR = a.con(:,21);

S2 = a.con(:,22);
S2 = (((DAE.x(a.omega)-1) < 0) | S2) & S2 >= 0;

if ty1
  VS = - Kw(ty1).*DAE.x(a.omega(ty1)) ...
       - Kp(ty1).*DAE.y(a.p(ty1)) ...
       - Kv(ty1).*DAE.y(a.vbus(ty1)) - DAE.x(a.v1(ty1));
  DAE.f(a.v1(ty1)) = a.u(ty1).*VS./Tw(ty1);
end

if tya
  y = (Kw+Kp+Kv).*VSI+DAE.x(a.v1);
  DAE.f(a.v1(tya)) = -a.u(tya).*y(tya)./Tw(tya);
end

if ty2
  A = T1(ty2)./T2(ty2);
  B = 1-A;
  C = T3(ty2)./T4(ty2);
  D = 1-C;
  DAE.f(a.v2(ty2)) = a.u(ty2).*(B.*y(ty2)-DAE.x(a.v2(ty2)))./T2(ty2);
  DAE.f(a.v3(ty2)) = a.u(ty2).*(D.*(DAE.x(a.v2(ty2))+A.*y(ty2))-DAE.x(a.v3(ty2)))./T4(ty2);
end
  
if ty3
  DAE.f(a.v2(ty3)) = a.u(ty3).*DAE.x(a.v3(ty3));
  DAE.f(a.v3(ty3)) = a.u(ty3).*(y(ty3)-T4(ty3).*DAE.x(a.v3(ty3))-DAE.x(a.v2(ty3)))./T2(ty3);
end

if tyb
  a.s1 = (a.s1 | (DAE.y(a.vf) < ETHR)) & (DAE.x(a.omega) >= WTHR);
  DAE.f(a.va(tyb)) = a.u(tyb).*a.s1(tyb).*(Ka(tyb).*VSI(tyb)-DAE.x(a.va(tyb)))./Ta(tyb);
  % non-windup limit
  fm_windup(a.va(tyb),a.con(tyb,16),0,'f')
  DAE.x(a.va(tyb)) = a.u(tyb).*min(S2(tyb).*DAE.x(a.va(tyb)),a.con(tyb,17));
end
