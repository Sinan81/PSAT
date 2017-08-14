function Gycall(a)

global DAE

if ~a.n, return, end

DAE.Gy = DAE.Gy ...
         - sparse(a.vbus,a.vbus,a.u.*DAE.x(a.ist),DAE.m,DAE.m) ...
         - sparse(a.vref,a.vref,1,DAE.m,DAE.m);
         

