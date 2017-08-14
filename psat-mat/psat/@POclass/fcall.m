function fcall(p)

global DAE

if ~p.n, return, end

Kw = p.con(:,7);
Tw = p.con(:,8);
T1 = p.con(:,9);
T2 = p.con(:,10);
T3 = p.con(:,11);
T4 = p.con(:,12);

VSI = vsi(p);

A = T1./T2;
B = 1 - A;

S1 = Kw.*VSI - DAE.x(p.v1);

DAE.f(p.v1) = p.u.*S1./Tw;
DAE.f(p.v2) = p.u.*(S1 - DAE.x(p.v2))./T2;
DAE.f(p.v3) = p.u.*(A.*S1 + B.*DAE.x(p.v2) - DAE.x(p.v3))./T4;

