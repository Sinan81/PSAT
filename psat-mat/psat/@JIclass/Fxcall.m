function Fxcall(a)

global DAE

if ~a.n, return, end

iTf = a.u./a.con(:,5);
Kv = a.u.*a.con(:,12);

DAE.Fx = DAE.Fx + sparse(a.x,a.x,-iTf,DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(a.x,a.vbus,-iTf.*iTf,DAE.n,DAE.m);
DAE.Gx = DAE.Gx + sparse(a.vbus,a.x,Kv,DAE.m,DAE.n);
