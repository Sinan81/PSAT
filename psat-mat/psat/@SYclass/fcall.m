function fcall(a)

global DAE Settings

if ~a.n, return, end

ord = a.con(:,5);
rad = 2*pi*Settings.freq;

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

ag = DAE.y(a.bus);
vg = a.u.*DAE.y(a.vbus);
ss = sin(delta-ag);
cc = cos(delta-ag);

iM = a.u./a.con(:,18);
D = a.con(:,19);

ra   = a.con(:,7);
xd   = a.con(:,8);    xq   = a.con(:,13);
xd1  = a.con(:,9);    xq1  = a.con(:,14);
xd2  = a.con(:,10);   xq2  = a.con(:,15);
Td10 = a.con(:,11);   Tq10 = a.con(:,16);
Td20 = a.con(:,12);   Tq20 = a.con(:,17);
Kw   = a.con(:,20);   Kp   = a.con(:,21);

% updating Vf and Pm
Vf = DAE.y(a.vf) + Kw.*(omega-1) - Kp.*(DAE.y(a.p)-a.Pg0);

DAE.f(a.delta) = rad*a.u.*(omega-1);
DAE.f(a.omega) = (DAE.y(a.pm)-DAE.y(a.p)-ra.*(a.Id.^2+a.Iq.^2)-D.*(omega-1)).*iM;

% Model III
if ~isempty(is3)
  e1q(is3) = DAE.x(a.e1q(is3));
  a34 = a.u(is3)./Td10(is3);
  a35 = a34.*(xd(is3)-xd1(is3));
  DAE.f(a.e1q(is3)) = -a34.*synsat(a,1,e1q(is3),is3) - a35.*a.Id(is3) + a34.*Vf(is3);
end

% Model IV
if ~isempty(is4)
  e1d(is4) = DAE.x(a.e1d(is4));
  e1q(is4) = DAE.x(a.e1q(is4));
  a44 = a.u(is4)./Td10(is4);
  a45 = a44.*(xd(is4)-xd1(is4));
  b43 = a.u(is4)./Tq10(is4);
  b44 = b43.*(xq(is4)-xq1(is4));
  DAE.f(a.e1q(is4)) = -a44.*synsat(a,1,e1q(is4),is4) - a45.*a.Id(is4) + a44.*Vf(is4);
  DAE.f(a.e1d(is4)) = -b43.*e1d(is4) + b44.*a.Iq(is4);
end

% Model V Type 1
if ~isempty(is51)
  e1d(is51) = DAE.x(a.e1d(is51));
  e1q(is51) = DAE.x(a.e1q(is51));
  e2d(is51) = DAE.x(a.e2d(is51));
  gq = xd1(is51)./xq1(is51).*Tq20(is51)./Tq10(is51).*(xq(is51)-xq1(is51));
  a514 = a.u(is51)./Td10(is51);
  a515 = a514.*(xd(is51)-xd1(is51));
  b511 = a.u(is51)./Tq20(is51);
  b512 = b511.*(xq1(is51)-xd1(is51)+gq);
  b513 = a.u(is51)./Tq10(is51);
  b514 = b513.*(xq(is51)-xq1(is51)-gq);
  DAE.f(a.e1q(is51)) = -a514.*synsat(a,1,e1q(is51),is51) - a515.*a.Id(is51) + a514.*Vf(is51);
  DAE.f(a.e1d(is51)) = -b513.*e1d(is51) + b514.*a.Iq(is51);
  DAE.f(a.e2d(is51)) = -b511.*e2d(is51) + b511.*e1d(is51) + b512.*a.Iq(is51);
end

% Model V Type 2
if ~isempty(is52)
  e1q(is52) = DAE.x(a.e1q(is52));
  e2q(is52) = DAE.x(a.e2q(is52));
  e2d(is52) = DAE.x(a.e2d(is52));
  Taa = a.con(:,24);
  gd = xd2(is52)./xd1(is52).*Td20(is52)./Td10(is52).*(xd(is52)-xd1(is52));
  a521 = a.u(is52)./Td20(is52);
  a522 = a521.*(xd1(is52)-xd2(is52)+gd);
  a523 = a.u(is52).*Taa(is52)./Td10(is52)./Td20(is52);
  a524 = a.u(is52)./Td10(is52);
  a525 = a524.*(xd(is52)-xd1(is52)-gd);
  a526 = a524.*(1-Taa(is52)./Td10(is52));
  b521 = a.u(is52)./Tq20(is52);
  b522 = b521.*(xq(is52)-xq2(is52));
  DAE.f(a.e1q(is52)) = -a524.*synsat(a,1,e1q(is52),is52) - a525.*a.Id(is52) + a526.*Vf(is52);
  DAE.f(a.e2q(is52)) = -a521.*e2q(is52) + a521.*e1q(is52) - a522.*a.Id(is52) + a523.*Vf(is52);
  DAE.f(a.e2d(is52)) = -b521.*e2d(is52) + b522.*a.Iq(is52);
end

% Model V Type 3
if ~isempty(is53)
  e1q(is53) = DAE.x(a.e1q(is53));
  psid(is53) = DAE.x(a.psid(is53));
  psiq(is53) = DAE.x(a.psiq(is53));
  a531 = (xd(is53)-xd1(is53))./xd(is53);
  a532 = a.u(is53)./(1-a531);
  a534 = a.u(is53)./Td10(is53);
  DAE.f(a.psiq(is53)) = rad.*(vg(is53).*cc(is53) + ra(is53).*a.Iq(is53) - omega(is53).*psid(is53));
  DAE.f(a.psid(is53)) = rad.*(vg(is53).*ss(is53) + ra(is53).*a.Id(is53) + omega(is53).*psiq(is53));
  DAE.f(a.e1q(is53)) = (a534.*(Vf(is53)-e1q(is53))- a531.*DAE.f(a.psid(is53))).*a532;
end

% Model VI
if ~isempty(is6)
  e1d(is6) = DAE.x(a.e1d(is6));
  e1q(is6) = DAE.x(a.e1q(is6));
  e2d(is6) = DAE.x(a.e2d(is6));
  e2q(is6) = DAE.x(a.e2q(is6));
  Taa = a.con(:,24);
  gd = xd2(is6)./xd1(is6).*Td20(is6)./Td10(is6).*(xd(is6)-xd1(is6));
  gq = xq2(is6)./xq1(is6).*Tq20(is6)./Tq10(is6).*(xq(is6)-xq1(is6));
  a1 = a.u(is6)./Td20(is6);
  a2 = a1.*(xd1(is6)-xd2(is6)+gd);
  a3 = a.u(is6).*Taa(is6)./Td10(is6)./Td20(is6);
  a4 = a.u(is6)./Td10(is6);
  a5 = a4.*(xd(is6)-xd1(is6)-gd);
  a6 = a4.*(1-Taa(is6)./Td10(is6));
  b1 = a.u(is6)./Tq20(is6);
  b2 = b1.*(xq1(is6)-xq2(is6)+gq);
  b3 = a.u(is6)./Tq10(is6);
  b4 = b3.*(xq(is6)-xq1(is6)-gq);
  DAE.f(a.e1q(is6)) = -a4.*synsat(a,1,e1q(is6),is6) - a5.*a.Id(is6) + a6.*Vf(is6);
  DAE.f(a.e1d(is6)) = -b3.*e1d(is6) + b4.*a.Iq(is6);
  DAE.f(a.e2q(is6)) = -a1.*e2q(is6) + a1.*e1q(is6) - a2.*a.Id(is6) + a3.*Vf(is6);
  DAE.f(a.e2d(is6)) = -b1.*e2d(is6) + b1.*e1d(is6) + b2.*a.Iq(is6);
end

% Model VIII
if ~isempty(is8)
  e1d(is8) = DAE.x(a.e1d(is8));
  e1q(is8) = DAE.x(a.e1q(is8));
  e2d(is8) = DAE.x(a.e2d(is8));
  e2q(is8) = DAE.x(a.e2q(is8));
  psid(is8) = DAE.x(a.psid(is8));
  psiq(is8) = DAE.x(a.psiq(is8));
  Taa = a.con(:,24);
  gd = xd2(is8)./xd1(is8).*Td20(is8)./Td10(is8).*(xd(is8)-xd1(is8));
  gq = xq2(is8)./xq1(is8).*Tq20(is8)./Tq10(is8).*(xq(is8)-xq1(is8));
  a18 = a.u(is8)./Td20(is8);
  a28 = a18.*(xd1(is8)-xd2(is8)+gd);
  a38 = a.u(is8).*Taa(is8)./Td10(is8)./Td20(is8);
  a48 = a.u(is8)./Td10(is8);
  a58 = a48.*(xd(is8)-xd1(is8)-gd);
  a68 = a48.*(1-Taa(is8)./Td10(is8));
  b18 = a.u(is8)./Tq20(is8);
  b28 = b18.*(xq1(is8)-xq2(is8)+gq);
  b38 = a.u(is8)./Tq10(is8);
  b48 = b38.*(xq(is8)-xq1(is8)-gq);
  DAE.f(a.e1q(is8)) = -a48.*synsat(a,1,e1q(is8),is8) - a58.*a.Id(is8) + a68.*Vf(is8);
  DAE.f(a.e1d(is8)) = -b38.*e1d(is8) + b48.*a.Iq(is8);
  DAE.f(a.e2q(is8)) = -a18.*e2q(is8) + a18.*e1q(is8) - a28.*a.Id(is8) + a38.*Vf(is8);
  DAE.f(a.e2d(is8)) = -b18.*e2d(is8) + b18.*e1d(is8) + b28.*a.Iq(is8);
  DAE.f(a.psiq(is8)) = rad*(vg(is8).*cc(is8) + ra(is8).*a.Iq(is8) - omega(is8).*psid(is8));
  DAE.f(a.psid(is8)) = rad*(vg(is8).*ss(is8) + ra(is8).*a.Id(is8) + omega(is8).*psiq(is8));
end
