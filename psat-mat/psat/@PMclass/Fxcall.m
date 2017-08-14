function Fxcall(a)

global DAE

if ~a.n, return, end

DAE.Fx = DAE.Fx - sparse(a.vm,a.vm,a.dat(:,1),DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.thetam,a.thetam,a.dat(:,2),DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(a.vm,a.vbus,a.u.*a.dat(:,1),DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.thetam,a.bus,a.u.*a.dat(:,2),DAE.n,DAE.m);
