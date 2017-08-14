function a = gcall(a)

global DAE

if ~a.n, return, end

ord = a.con(:,5);

is2  = find(ord == 2);
is3  = find(ord == 3);
is4  = find(ord == 4);
is51 = find(ord == 5.1);
is52 = find(ord == 5.2);
is53 = find(ord == 5.3);
is6  = find(ord == 6);
is8  = find(ord == 8);

delta = DAE.x(a.delta);
omega = DAE.x(a.omega);
e1q = zeros(a.n,1);
e1d = zeros(a.n,1);
e2q = zeros(a.n,1);
e2d = zeros(a.n,1);
psiq = zeros(a.n,1);
psid = zeros(a.n,1);

xd   = a.con(:,8);
xq   = a.con(:,13);
xd2  = a.con(:,10);
xq2  = a.con(:,15);

ag = DAE.y(a.bus);
vg = a.u.*DAE.y(a.vbus);
ss = sin(delta-ag);
cc = cos(delta-ag);

a.Id = -vg.*(a.c1.*ss+a.c3.*cc);
a.Iq =  vg.*(a.c2.*ss-a.c1.*cc);

if ~isempty(is2)
  Kw = a.con(is2,20);
  Kp = a.con(is2,21);
  Vf = DAE.y(a.vf(is2)) + Kw.*(omega(is2)-1) - Kp.*(DAE.y(a.p(is2))-a.Pg0(is2));
  a.Id(is2) = a.Id(is2) + a.c3(is2).*Vf.*a.u(is2);
  a.Iq(is2) = a.Iq(is2) + a.c1(is2).*Vf.*a.u(is2);
end

if ~isempty(is3)
  e1q(is3) = DAE.x(a.e1q(is3));
  a.Id(is3) = a.Id(is3) + a.c3(is3).*e1q(is3);
  a.Iq(is3) = a.Iq(is3) + a.c1(is3).*e1q(is3);
end

if ~isempty(is4)
  e1d(is4) = DAE.x(a.e1d(is4));
  e1q(is4) = DAE.x(a.e1q(is4));
  a.Id(is4) = a.Id(is4) + a.c1(is4).*e1d(is4) + a.c3(is4).*e1q(is4);
  a.Iq(is4) = a.Iq(is4) - a.c2(is4).*e1d(is4) + a.c1(is4).*e1q(is4);
end

if ~isempty(is51)
  e1d(is51) = DAE.x(a.e1d(is51));
  e1q(is51) = DAE.x(a.e1q(is51));
  e2d(is51) = DAE.x(a.e2d(is51));
  a.Id(is51) = a.Id(is51) + a.c1(is51).*e2d(is51) + a.c3(is51).*e1q(is51);
  a.Iq(is51) = a.Iq(is51) - a.c2(is51).*e2d(is51) + a.c1(is51).*e1q(is51);
end

if ~isempty(is52)
  e1q(is52) = DAE.x(a.e1q(is52));
  e2q(is52) = DAE.x(a.e2q(is52));
  e2d(is52) = DAE.x(a.e2d(is52));
  a.Id(is52) = a.Id(is52) + a.c1(is52).*e2d(is52) + a.c3(is52).*e2q(is52);
  a.Iq(is52) = a.Iq(is52) - a.c2(is52).*e2d(is52) + a.c1(is52).*e2q(is52);
end

if ~isempty(is53)
  e1q(is53) = DAE.x(a.e1q(is53));
  psid(is53) = DAE.x(a.psid(is53));
  psiq(is53) = DAE.x(a.psiq(is53));
  a.Id(is53) = (e1q(is53)-psid(is53))./xd(is53);
  a.Iq(is53) = -psiq(is53)./xq(is53);
end

if ~isempty(is6)
  e1d(is6) = DAE.x(a.e1d(is6));
  e1q(is6) = DAE.x(a.e1q(is6));
  e2d(is6) = DAE.x(a.e2d(is6));
  e2q(is6) = DAE.x(a.e2q(is6));
  a.Id(is6) = a.Id(is6) + a.c1(is6).*e2d(is6) + a.c3(is6).*e2q(is6);
  a.Iq(is6) = a.Iq(is6) - a.c2(is6).*e2d(is6) + a.c1(is6).*e2q(is6);
end

if ~isempty(is8)
  e1d(is8) = DAE.x(a.e1d(is8));
  e1q(is8) = DAE.x(a.e1q(is8));
  e2d(is8) = DAE.x(a.e2d(is8));
  e2q(is8) = DAE.x(a.e2q(is8));
  psid(is8) = DAE.x(a.psid(is8));
  psiq(is8) = DAE.x(a.psiq(is8));
  a.Id(is8) =  (e2q(is8)-psid(is8))./xd2(is8);
  a.Iq(is8) = -(e2d(is8)+psiq(is8))./xq2(is8);
end

DAE.g = DAE.g ...
        - sparse(a.bus,1,DAE.y(a.p),DAE.m,1) ...
        - sparse(a.vbus,1,DAE.y(a.q),DAE.m,1) ...
        + sparse(a.p,1,vg.*(a.Id.*ss+a.Iq.*cc)-DAE.y(a.p),DAE.m,1) ...
        + sparse(a.q,1,vg.*(a.Id.*cc-a.Iq.*ss)-DAE.y(a.q),DAE.m,1) ...
        + sparse(a.pm,1,a.u.*(a.pm0-DAE.y(a.pm)),DAE.m,1) ...
        + sparse(a.vf,1,a.u.*(a.vf0-DAE.y(a.vf)),DAE.m,1);
