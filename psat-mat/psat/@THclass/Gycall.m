function Gycall(a)

global DAE

if ~a.n, return, end

V = a.u.*DAE.y(a.vbus);

DAE.Gy = DAE.Gy ... 
  + sparse(a.bus,a.vbus,2*DAE.y(a.G).*V,DAE.m,DAE.m) ...
  - sparse(a.G,a.G,a.u,DAE.m,DAE.m) ...
  + sparse(a.bus,a.G,V.*V,DAE.m,DAE.m);
