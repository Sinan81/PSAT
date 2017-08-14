function Fxcall(a)

global DAE Settings

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

bs2  = a.bus(is2);
bs3  = a.bus(is3);
bs4  = a.bus(is4);
bs51 = a.bus(is51);
bs52 = a.bus(is52);
bs53 = a.bus(is53);
bs6  = a.bus(is6);
bs8  = a.bus(is8);

vs2  = a.vbus(is2);
vs3  = a.vbus(is3);
vs4  = a.vbus(is4);
vs51 = a.vbus(is51);
vs52 = a.vbus(is52);
vs53 = a.vbus(is53);
vs6  = a.vbus(is6);
vs8  = a.vbus(is8);

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

M1 =  vg.*(a.c1.*cc-a.c3.*ss);
M2 = -vg.*(a.c2.*cc+a.c1.*ss);
M3 = -(a.c1.*ss+a.c3.*cc).*a.u;
M4 =  (a.c2.*ss-a.c1.*cc).*a.u;

rad = 2*pi*Settings.freq;
Wn = rad*a.u;

% common Jacobians
DAE.Fx = DAE.Fx - sparse(a.delta,a.delta,(~a.u),DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.delta,a.omega,Wn,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega,a.omega,iM.*D+(~a.u),DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega,a.delta,2*ra.*(a.Id.*M1+a.Iq.*M2).*iM,DAE.n,DAE.n);
DAE.Fy = DAE.Fy - sparse(a.omega,a.bus,2*ra.*(a.Id.*M1+a.Iq.*M2).*iM,DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(a.omega,a.vbus,2*ra.*(a.Id.*M3+a.Iq.*M4).*iM,DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(a.omega,a.p,iM,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.omega,a.pm,iM,DAE.n,DAE.m);
DAE.Gx = DAE.Gx + sparse(a.p,a.delta,a.J11,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.q,a.delta,a.J21,DAE.m,DAE.n);

Gp1 = vg.*(a.c3.*ss + a.c1.*cc);
Gp2 = vg.*(a.c1.*ss - a.c2.*cc);
Gq1 = vg.*(a.c3.*cc - a.c1.*ss);
Gq2 = vg.*(a.c1.*cc + a.c2.*ss);

N1 = -2*ra.*(a.Id.*a.c3+a.Iq.*a.c1).*iM;
N2 = -2*ra.*(a.Id.*a.c1-a.Iq.*a.c2).*iM;

% Model II
if ~isempty(is2)
  o2 = a.omega(is2);
  q1 = vg(is2).*(ss(is2).*a.c3(is2)+cc(is2).*a.c1(is2));
  q2 = vg(is2).*(cc(is2).*a.c3(is2)-ss(is2).*a.c1(is2));
  k2 = 2*ra(is2).*iM(is2).*(a.c3(is2).*a.Id(is2)+a.c1(is2).*a.Iq(is2));
  DAE.Fy = DAE.Fy - sparse(o2,a.vf(is2),k2,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(o2,a.p(is2),Kp(is2).*k2,DAE.n,DAE.m);
  DAE.Fx = DAE.Fx - sparse(o2,o2,Kw(is2).*k2,DAE.n,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.p(is2),o2,Kw(is2).*q1,DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.q(is2),o2,Kw(is2).*q2,DAE.m,DAE.n);
end

% Model III
if (~isempty(is3))
  o3 = a.omega(is3);
  e1q3 = a.e1q(is3);
  e1q(is3) = DAE.x(e1q3);
  a34 = a.u(is3)./Td10(is3);
  a35 = a34.*(xd(is3)-xd1(is3));
  DAE.Fx = DAE.Fx + sparse(o3,e1q3,N1(is3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q3,a.delta(is3),a35.*M1(is3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q3,o3,a34.*Kw(is3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q3,e1q3,a34.*synsat(a,2,e1q(is3),is3)+a35.*a.c3(is3)+(~a.u(is3)),DAE.n,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.p(is3),e1q3,Gp1(is3),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.q(is3),e1q3,Gq1(is3),DAE.m,DAE.n);
  DAE.Fy = DAE.Fy + sparse(e1q3,a.vf(is3),a34,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q3,bs3,a35.*M1(is3),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q3,vs3,a35.*M3(is3),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q3,a.p(is3),a34.*Kp(is3),DAE.n,DAE.m);
end

% Model IV
if ~isempty(is4)
  o4 = a.omega(is4);
  e1q4 = a.e1q(is4);
  e1d4 = a.e1d(is4);
  e1d(is4) = DAE.x(e1d4);
  e1q(is4) = DAE.x(e1q4);
  a44 = a.u(is4)./Td10(is4);
  a45 = a44.*(xd(is4)-xd1(is4));
  b43 = a.u(is4)./Tq10(is4);
  b44 = b43.*(xq(is4)-xq1(is4));
  DAE.Fy = DAE.Fy + sparse(e1q4,a.vf(is4),a44,DAE.n,DAE.m);
  DAE.Fx = DAE.Fx + sparse(o4,e1q4,N1(is4),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(o4,e1d4,N2(is4),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q4,a.delta(is4),a45.*M1(is4),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q4,o4,a44.*Kw(is4),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q4,e1q4,a44.*synsat(a,2,e1q(is4),is4)+a45.*a.c3(is4)+(~a.u(is4)), DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q4,e1d4,a45.*a.c1(is4), DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1d4,a.delta(is4),b44.*M2(is4), DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1d4,e1q4,b44.*a.c1(is4), DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1d4,e1d4,b43+b44.*a.c2(is4)+(~a.u(is4)), DAE.n,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.p(is4),e1q4,Gp1(is4),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.p(is4),e1d4,Gp2(is4),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.q(is4),e1q4,Gq1(is4),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.q(is4),e1d4,Gq2(is4),DAE.m,DAE.n);
  DAE.Fy = DAE.Fy - sparse(e1q4,bs4,a45.*M1(is4),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q4,vs4,a45.*M3(is4),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e1d4,bs4,b44.*M2(is4),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e1d4,vs4,b44.*M4(is4),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q4,a.p(is4),a44.*Kp(is4),DAE.n,DAE.m);
end

% Model V Type 1
if(~isempty(is51))
  o51 = a.omega(is51);
  e1q51 = a.e1q(is51);
  e1d51 = a.e1d(is51);
  e2d51 = a.e2d(is51);
  e1d(is51) = DAE.x(e1d51);
  e1q(is51) = DAE.x(e1q51);
  e2d(is51) = DAE.x(e2d51);
  gq = xd1(is51)./xq1(is51).*Tq20(is51)./Tq10(is51).*(xq(is51)-xq1(is51));
  a514 = a.u(is51)./Td10(is51);
  a515 = a514.*(xd(is51)-xd1(is51));
  b511 = a.u(is51)./Tq20(is51);
  b512 = b511.*(xq1(is51)-xd1(is51)+gq);
  b513 = a.u(is51)./Tq10(is51);
  b514 = b513.*(xq(is51)-xq1(is51)-gq);
  DAE.Fy = DAE.Fy + sparse(e1q51,a.vf(is51),a514,DAE.n,DAE.m);
  DAE.Fx = DAE.Fx + sparse(o51,e1q51,N1(is51),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(o51,e2d51,N2(is51),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q51,a.delta(is51),a515.*M1(is51),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q51,o51,a514.*Kw(is51),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q51,e1q51,a514.*synsat(a,2,e1q(is51),is51)+a515.*a.c3(is51)+(~a.u(is51)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q51,e2d51,a515.*a.c1(is51),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1d51,a.delta(is51),b514.*M2(is51),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1d51,e1q51,b514.*a.c1(is51),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1d51,e1d51,b513+(~a.u(is51)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1d51,e2d51,b514.*a.c2(is51),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2d51,a.delta(is51),b512.*M2(is51),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2d51,e1q51,b512.*a.c1(is51),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2d51,e1d51,b511,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2d51,e2d51,b511+b512.*a.c2(is51)+(~a.u(is51)),DAE.n,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.p(is51),e1q51,Gp1(is51),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.p(is51),e2d51,Gp2(is51),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.q(is51),e1q51,Gq1(is51),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.q(is51),e2d51,Gq2(is51),DAE.m,DAE.n);
  DAE.Fy = DAE.Fy - sparse(e1q51,bs51,a515.*M1(is51),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q51,vs51,a515.*M3(is51),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e1d51,bs51,b514.*M2(is51),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e1d51,vs51,b514.*M4(is51),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e2d51,bs51,b512.*M2(is51),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e2d51,vs51,b512.*M4(is51),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q51,a.p(is51),a514.*Kp(is51),DAE.n,DAE.m);
end

% Model V Type 2
if(~isempty(is52))
  o52 = a.omega(is52);
  e1q52 = a.e1q(is52);
  e2q52 = a.e2q(is52);
  e2d52 = a.e2d(is52);
  e1q(is52) = DAE.x(e1q52);
  e2q(is52) = DAE.x(e2q52);
  e2d(is52) = DAE.x(e2d52);
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
  DAE.Fx = DAE.Fx + sparse(o52,e2q52,N1(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(o52,e2d52,N2(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q52,a.delta(is52),a525.*M1(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q52,o52,a526.*Kw(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q52,e1q52,a524.*synsat(a,2,e1q(is52),is52)+(~a.u(is52)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q52,e2q52,a525.*a.c3(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q52,e2d52,a525.*a.c1(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2q52,a.delta(is52),a522.*M1(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2q52,o52,a523.*Kw(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2q52,e1q52,a521,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2q52,e2q52,a521+a522.*a.c3(is52)+(~a.u(is52)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2q52,e2d52,a522.*a.c1(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2d52,a.delta(is52),b522.*M2(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2d52,e2q52,b522.*a.c1(is52),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2d52,e2d52,b521+b522.*a.c2(is52)+(~a.u(is52)),DAE.n,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.p(is52),e2q52,Gp1(is52),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.p(is52),e2d52,Gp2(is52),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.q(is52),e2q52,Gq1(is52),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.q(is52),e2d52,Gq2(is52),DAE.m,DAE.n);
  DAE.Fy = DAE.Fy + sparse(e1q52,a.vf(is52),a526,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e2q52,a.vf(is52),a523,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q52,bs52,a525.*M1(is52),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q52,vs52,a525.*M3(is52),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e2q52,bs52,a522.*M1(is52),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e2q52,vs52,a522.*M3(is52),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e2d52,bs52,b522.*M2(is52),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e2d52,vs52,b522.*M4(is52),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q52,a.p(is52),a526.*Kp(is52),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e2q52,a.p(is52),a523.*Kp(is52),DAE.n,DAE.m);
end

% Model V Type 3
if (~isempty(is53))
  Wn = rad*a.u(is53);
  d53 = a.delta(is53);
  o53 = a.omega(is53);
  e1q53 = a.e1q(is53);
  psid53 = a.psid(is53);
  psiq53 = a.psiq(is53);
  e1q(is53) = DAE.x(e1q53);
  psid(is53) = DAE.x(psid53);
  psiq(is53) = DAE.x(psiq53);
  a531 = (xd(is53)-xd1(is53))./xd(is53);
  a532 = a.u(is53)./(1-a531);
  a534 = a.u(is53)./Td10(is53);
  c534 = a.u(is53)./xd(is53);
  c535 = a.u(is53)./xq(is53);
  q1 = -2*ra(is53).*(e1q(is53)-psid(is53)).*c534.*c534.*iM(is53);
  q2 = -2*ra(is53).*psiq(is53).*c535.*c535.*iM(is53);
  q3 = -(a534+a531.*Wn.*ra(is53).*c534).*a532;
  q4 = a531.*Wn.*ra(is53).*c534.*a532;
  DAE.Fx = DAE.Fx + sparse(o53,e1q53,q1,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(o53,psiq53,q2,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(o53,psid53,q1,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q53,d53,a531.*Wn.*vg(is53).*cc(is53).*a532,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q53,o53,a531.*Wn.*psiq(is53).*a532,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q53,o53,a532.*a534.*Kw(is53),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q53,e1q53,q3-(~a.u(is53)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q53,psiq53,a531.*Wn.*omega(is53).*a532,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q53,psid53,q4,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(psiq53,d53,Wn.*vg(is53).*ss(is53),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(psiq53,o53,Wn.*psid(is53),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(psiq53,psiq53,Wn.*ra(is53).*c535+(~a.u(is53)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(psiq53,psid53,Wn.*omega(is53),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(psid53,d53,Wn.*vg(is53).*cc(is53),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(psid53,o53,Wn.*psiq(is53),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(psid53,e1q53,Wn.*ra(is53).*c534,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(psid53,psiq53,Wn.*omega(is53),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(psid53,psid53,Wn.*ra(is53).*c534+(~a.u(is53)),DAE.n,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.p(is53),e1q53,vg(is53).*c534.*ss(is53),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(a.p(is53),psiq53,vg(is53).*c535.*cc(is53),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(a.p(is53),psid53,vg(is53).*c534.*ss(is53),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.q(is53),e1q53,vg(is53).*c534.*cc(is53),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.q(is53),psiq53,vg(is53).*c535.*ss(is53),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(a.q(is53),psid53,vg(is53).*c534.*cc(is53),DAE.m,DAE.n);
  DAE.Fy = DAE.Fy + sparse(e1q53,a.vf(is53),a532.*a534,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q53,a.p(is53),a532.*a534.*Kp(is53),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e1q53,bs53,a531.*Wn.*vg(is53).*cc(is53).*a532,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q53,vs53,a531.*Wn.*ss(is53).*a532,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(psiq53,bs53,Wn.*vg(is53).*ss(is53),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(psiq53,vs53,Wn.*cc(is53),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(psid53,bs53,Wn.*vg(is53).*cc(is53),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(psid53,vs53,Wn.*ss(is53),DAE.n,DAE.m);
end

% Model VI
if(~isempty(is6))
  o6 = a.omega(is6);
  e1q6 = a.e1q(is6);
  e1d6 = a.e1d(is6);
  e2q6 = a.e2q(is6);
  e2d6 = a.e2d(is6);
  e1d(is6) = DAE.x(e1d6);
  e1q(is6) = DAE.x(e1q6);
  e2d(is6) = DAE.x(e2d6);
  e2q(is6) = DAE.x(e2q6);
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
  p6 = a.p(is6);
  q6 = a.q(is6);
  DAE.Fx = DAE.Fx + sparse(o6,e2q6,N1(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(o6,e2d6,N2(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q6,a.delta(is6),a5.*M1(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q6,o6,a6.*Kw(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q6,e1q6,a4.*synsat(a,2,e1q(is6),is6)+(~a.u(is6)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q6,e2q6,a5.*a.c3(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q6,e2d6,a5.*a.c1(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1d6,a.delta(is6),b4.*M2(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1d6,e1d6,b3+(~a.u(is6)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1d6,e2q6,b4.*a.c1(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1d6,e2d6,b4.*a.c2(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2q6,a.delta(is6),a2.*M1(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2q6,o6,a3.*Kw(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2q6,e1q6,a1,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2q6,e2q6,a1+a2.*a.c3(is6)+(~a.u(is6)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2q6,e2d6,a2.*a.c1(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2d6,a.delta(is6),b2.*M2(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2d6,e1d6,b1,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2d6,e2q6,b2.*a.c1(is6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2d6,e2d6,b1+b2.*a.c2(is6)+(~a.u(is6)),DAE.n,DAE.n);
  DAE.Gx = DAE.Gx + sparse(p6,e2q6,Gp1(is6),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(p6,e2d6,Gp2(is6),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(q6,e2q6,Gq1(is6),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(q6,e2d6,Gq2(is6),DAE.m,DAE.n);
  DAE.Fy = DAE.Fy + sparse(e1q6,a.vf(is6),a6,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e2q6,a.vf(is6),a3,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q6,bs6,a5.*M1(is6),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q6,vs6,a5.*M3(is6),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e1d6,bs6,b4.*M2(is6),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e1d6,vs6,b4.*M4(is6),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e2q6,bs6,a2.*M1(is6),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e2q6,vs6,a2.*M3(is6),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e2d6,bs6,b2.*M2(is6),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e2d6,vs6,b2.*M4(is6),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q6,p6,a6.*Kp(is6),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e2q6,p6,a3.*Kp(is6),DAE.n,DAE.m);
end

% Model VIII
if ~isempty(is8)
  Wn = rad*a.u(is8);
  d8 = a.delta(is8);
  o8 = a.omega(is8);
  e1q8 = a.e1q(is8);
  e1d8 = a.e1d(is8);
  e2q8 = a.e2q(is8);
  e2d8 = a.e2d(is8);
  psid8 = a.psid(is8);
  psiq8 = a.psiq(is8);
  e1d(is8) = DAE.x(e1d8);
  e1q(is8) = DAE.x(e1q8);
  e2d(is8) = DAE.x(e2d8);
  e2q(is8) = DAE.x(e2q8);
  psid(is8) = DAE.x(psid8);
  psiq(is8) = DAE.x(psiq8);
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
  p8 = a.p(is8);
  q8 = a.q(is8);
  q1 = 2*ra(is8).*(e2d(is8)+psiq(is8))./xq2(is8).*iM(is8)./xq2(is8);
  q2 = 2*ra(is8).*(e2q(is8)-psid(is8))./xd2(is8).*iM(is8)./xd2(is8);
  DAE.Fx = DAE.Fx - sparse(o8,e2d8,q1,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(o8,e2q8,q2,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(o8,psiq8,q1,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(o8,psid8,q2,DAE.n,DAE.n);
  
  DAE.Fx = DAE.Fx + sparse(e1q8,o8,a68.*Kw(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q8,e1q8,a48.*synsat(a,2,e1q(is8),is8)+(~a.u(is8)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1q8,e2q8,a58./xd2(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e1q8,psid8,a58./xd2(is8),DAE.n,DAE.n);
  
  DAE.Fx = DAE.Fx - sparse(e1d8,e1d8,b38+(~a.u(is8)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1d8,e2d8,b48./xq2(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e1d8,psiq8,b48./xq2(is8),DAE.n,DAE.n);
  
  DAE.Fx = DAE.Fx + sparse(e2q8,o8,a38.*Kw(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2q8,e1q8,a18,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2q8,e2q8,a18+a28./xd2(is8)+(~a.u(is8)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(e2q8,psid8,a28./xd2(is8),DAE.n,DAE.n);
  
  DAE.Fx = DAE.Fx + sparse(e2d8,e1d8,b18,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2d8,e2d8,b18+b28./xq2(is8)+(~a.u(is8)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(e2d8,psiq8,b28./xq2(is8),DAE.n,DAE.n);
  
  DAE.Fx = DAE.Fx - sparse(psiq8,a.delta(is8),Wn.*vg(is8).*ss(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(psiq8,o8,Wn.*psid(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(psiq8,e2d8,Wn.*ra(is8)./xq2(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(psiq8,psiq8,Wn.*ra(is8)./xq2(is8)+(~a.u(is8)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(psiq8,psid8,Wn.*omega(is8),DAE.n,DAE.n);
  
  DAE.Fx = DAE.Fx + sparse(psid8,a.delta(is8),Wn.*vg(is8).*cc(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(psid8,o8,Wn.*psiq(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(psid8,e2q8,Wn.*ra(is8)./xd2(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(psid8,psiq8,Wn.*omega(is8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(psid8,psid8,Wn.*ra(is8)./xd2(is8)+(~a.u(is8)),DAE.n,DAE.n);
  
  DAE.Gx = DAE.Gx + sparse(p8,e2q8,vg(is8)./xd2(is8).*ss(is8),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(p8,e2d8,vg(is8)./xq2(is8).*cc(is8),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(p8,psiq8,vg(is8)./xq2(is8).*cc(is8),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(p8,psid8,vg(is8)./xd2(is8).*ss(is8),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(q8,e2q8,vg(is8)./xd2(is8).*cc(is8),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(q8,e2d8,vg(is8)./xq2(is8).*ss(is8),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(q8,psiq8,vg(is8)./xq2(is8).*ss(is8),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(q8,psid8,vg(is8)./xd2(is8).*cc(is8),DAE.m,DAE.n);
  
  DAE.Fy = DAE.Fy + sparse(e1q8,a.vf(is8),a68,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(e2q8,a.vf(is8),a38,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(psiq8,bs8,Wn.*vg(is8).*ss(is8),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(psiq8,vs8,Wn.*cc(is8),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(psid8,bs8,Wn.*vg(is8).*cc(is8),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(psid8,vs8,Wn.*ss(is8),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e1q8,p8,a68.*Kp(is8),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(e2q8,p8,a38.*Kp(is8),DAE.n,DAE.m);
end
