function a = dynidx(a)

global DAE Sssc Statcom Svc Tcsc Upfc Dfig

if ~a.n, return, end

m = 3;
k = [0:m:m*(a.n-1)]';

a.v1 = DAE.n + 1 + k;
a.v2 = DAE.n + 2 + k;
a.v3 = DAE.n + 3 + k;
a.Vs = DAE.m + [1:a.n]';

DAE.n = DAE.n + m*a.n;
DAE.m = DAE.m + a.n;

type = a.con(:,4);
a1 = find(type == 1);
a2 = find(type == 2);
a3 = find(type == 3);
a4 = find(type == 4);
a5 = find(type == 5);
a6 = find(type == 6);

a.svc = Svc.vref(a.con(a1,2));
a.tcsc = Tcsc.x0(a.con(a2,2));
a.statcom = Statcom.vref(a.con(a3,2));
a.sssc = Sssc.v0(a.con(a4,2));
[a.upfc,a.z] = getidx(Upfc,a.con(a5,2));
a.dfig = Dfig.vref(a.con(a6,2));

a.kr = getkr(Tcsc,a.con(a2,2));

% disconnect Pod if the FACTS is off-line
if a.svc,     a.u(a1) = a.u(a1).*Svc.u(a.con(a1,2));     end
if a.tcsc,    a.u(a2) = a.u(a2).*Tcsc.u(a.con(a2,2));    end
if a.statcom, a.u(a3) = a.u(a3).*Statcom.u(a.con(a3,2)); end
if a.sssc,    a.u(a4) = a.u(a4).*Sssc.u(a.con(a4,2));    end
if a.upfc,    a.u(a5) = a.u(a5).*Upfc.u(a.con(a5,2));    end
if a.dfig,    a.u(a6) = a.u(a6).*Dfig.u(a.con(a6,2));    end
