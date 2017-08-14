function Gycall(p)

global DAE

if ~p.n, return, end

V = 2*p.u.*DAE.y(p.vbus);

DAE.Gy  = DAE.Gy + ...
          sparse(p.bus, p.vbus,p.dat(:,1).*V,DAE.m,DAE.m) - ...
          sparse(p.vbus,p.vbus,p.dat(:,2).*V,DAE.m,DAE.m);

