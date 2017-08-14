function gcall(p)

global DAE

if ~p.n, return, end

V = DAE.y(p.vbus);
V2 = p.u.*V.*V;

DAE.g = DAE.g + ...
        sparse(p.bus,1,p.con(:,5).*V2,DAE.m,1) - ...
        sparse(p.vbus,1,p.con(:,6).*V2,DAE.m,1);
