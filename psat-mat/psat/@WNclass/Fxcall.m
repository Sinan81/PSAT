function Fxcall(a)

global DAE

if ~a.n, return, end

k = 1./a.con(:,4);
DAE.Fx = DAE.Fx - sparse(a.vw,a.vw,k,DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(a.vw,a.ws,k,DAE.n,DAE.m);
