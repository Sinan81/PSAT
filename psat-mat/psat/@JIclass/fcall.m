function fcall(a)

global DAE

if ~a.n, return, end

x = DAE.x(a.x);
V1 = DAE.y(a.vbus);
iTf = a.u./a.con(:,5);

DAE.f(a.x) = -(V1.*iTf+x).*iTf;
