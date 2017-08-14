function Fxcall(a)

global DAE Settings

if ~a.n, return, end

DAE.Fx = DAE.Fx - sparse(a.x,a.x,~a.u,DAE.n,DAE.n);
DAE.Fy = DAE.Fy - sparse(a.x,a.dw,a.u./a.con(:,8),DAE.n,DAE.m);
DAE.Gx = DAE.Gx + sparse(a.dw,a.x,a.u,DAE.m,DAE.n);
