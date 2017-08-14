function fcall(a)

global DAE

if ~a.n, return, end

x = DAE.x(a.x);
w = DAE.x(a.w);
theta = DAE.y(a.bus);
iTf = a.u./a.con(:,2);
iTw = a.u./a.con(:,3);
theta0 = a.dat(:,1);
k = a.dat(:,2);

DAE.f(a.x) = (k.*(theta-theta0)-x).*iTf;
DAE.f(a.w) = (-x+k.*(theta-theta0)+1-w).*iTw;
