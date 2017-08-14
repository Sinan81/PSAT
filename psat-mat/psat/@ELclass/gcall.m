function gcall(a)

global DAE

if ~a.n, return, end

V = DAE.y(a.vbus);
xp = DAE.x(a.xp);
xq = DAE.x(a.xq);
Tp = a.con(:,5);
Tq = a.con(:,6);
at = a.con(:,8);
bt = a.con(:,10);
P0 = a.dat(:,1);
Q0 = a.dat(:,2);
V0 = a.dat(:,3);

DAE.g = DAE.g + sparse(a.bus,1,a.u.*(xp./Tp+P0.*(V./V0).^at),DAE.m,1) ...
        + sparse(a.vbus,1,a.u.*(xq./Tq+Q0.*(V./V0).^bt),DAE.m,1);
