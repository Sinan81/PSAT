function Gycall(a)

global DAE

if ~a.n, return, end

DAE.Gy = DAE.Gy - sparse(a.ws,a.ws,1,DAE.m,DAE.m);
