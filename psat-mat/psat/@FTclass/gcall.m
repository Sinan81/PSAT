function gcall(p)

global DAE

if ~p.n, return, end

V = DAE.y(p.vbus);
V2 = p.u.*V.*V;

DAE.g = DAE.g + ...
        sparse(p.bus,1,p.dat(:,1).*V2,DAE.m,1) - ...
        sparse(p.vbus,1,p.dat(:,2).*V2,DAE.m,1);
