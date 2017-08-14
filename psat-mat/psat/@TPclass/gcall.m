function gcall(a)

global DAE

if ~a.n, return, end

m = DAE.x(a.m);
V = DAE.y(a.vbus);

DAE.g = DAE.g + sparse(a.bus,1,a.u.*a.con(:,9).*((V./m).^a.con(:,11)),DAE.m,1) ...
        + sparse(a.vbus,1,a.u.*a.con(:,10).*((V./m).^a.con(:,12)),DAE.m,1);
