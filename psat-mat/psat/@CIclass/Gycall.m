function Gycall(a)

global DAE

if ~a.n, return, end

DAE.Gy = DAE.Gy ...
         - sparse(a.delta,a.delta,1,DAE.m,DAE.m) ...
         - sparse(a.omega,a.omega,1,DAE.m,DAE.m);
