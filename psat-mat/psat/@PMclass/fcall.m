function fcall(a)

global DAE

if ~a.n, return, end

vm = DAE.x(a.vm);
thetam = DAE.x(a.thetam);
V1 = DAE.y(a.vbus);
theta1 = DAE.y(a.bus);

DAE.f(a.vm) = (V1-vm).*a.dat(:,1).*a.u;
DAE.f(a.thetam) = (theta1-thetam).*a.dat(:,2).*a.u;
