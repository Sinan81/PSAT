function gcall(a)

if ~a.n, return, end

global DAE

type = a.con(:,4);
a1 = find(type == 1);
a2 = find(type == 2);
a3 = find(type == 3);
a4 = find(type == 4);
a5 = find(type == 5);
a6 = find(type == 6);

Vs = a.u.*DAE.y(a.Vs);
Kw = a.con(:,7);
Tw = a.con(:,8);
T1 = a.con(:,9);
T2 = a.con(:,10);
T3 = a.con(:,11);
T4 = a.con(:,12);

VSI = vsi(a);

A = T1./T2;
B = 1 - A;
C = T3./T4;
D = 1 - C;

S1 = Kw.*VSI - DAE.x(a.v1);

if a1, DAE.g = DAE.g + sparse(a.svc,1,Vs(a1),DAE.m,1); end
if a2, DAE.g = DAE.g + sparse(a.tcsc,1,Vs(a2).*a.kr,DAE.m,1); end
if a3, DAE.g = DAE.g + sparse(a.statcom,1,Vs(a3),DAE.m,1); end
if a4, DAE.g = DAE.g + sparse(a.sssc,1,Vs(a4),DAE.m,1); end
if a5, DAE.g = DAE.g + sparse(a.upfc,1,Vs([a5;a5;a5]).*a.z,DAE.m,1); end
if a6, DAE.g = DAE.g + sparse(a.dfig,1,Vs(a6),DAE.m,1); end

DAE.y(a.Vs) = min(DAE.y(a.Vs), a.con(:,5));
DAE.y(a.Vs) = max(DAE.y(a.Vs), a.con(:,6));

u = a.u & DAE.y(a.Vs) < a.con(:,5) & DAE.y(a.Vs) > a.con(:,6);

DAE.g(a.Vs) = u.*(A.*C.*S1 + B.*C.*DAE.x(a.v2) + D.*DAE.x(a.v3) - DAE.y(a.Vs));
%DAE.g(a.Vs) = u.*(A.*C.*S1 + C.*DAE.x(a.v2) + DAE.x(a.v3) - DAE.y(a.Vs));

