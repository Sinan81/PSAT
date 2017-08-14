function Gycall(p)

global DAE

if ~p.n, return, end

V = 2*p.u.*DAE.y(p.vbus);

DAE.Gy  = DAE.Gy + ...
          sparse(p.bus, p.vbus,p.con(:,5).*V,DAE.m,DAE.m) - ...
          sparse(p.vbus,p.vbus,p.con(:,6).*V,DAE.m,DAE.m);

