function a = fcall_fl(a)

global DAE

if ~a.n, return, end

DAE.f(a.x) = -a.u.*DAE.y(a.dw)./a.con(:,8);
