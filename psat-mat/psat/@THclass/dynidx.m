function a = dynidx(a)

global DAE

if ~a.n, return, end

a.T = DAE.n + [1:2:2*a.n]';
a.x = DAE.n + [2:2:2*a.n]';
DAE.n = DAE.n + 2*a.n;

a.G = DAE.m + [1:a.n]';
DAE.m = DAE.m + a.n;