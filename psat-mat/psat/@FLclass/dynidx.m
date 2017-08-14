function a = dynidx(a)

global DAE

if ~a.n, return, end

a.x = DAE.n + [1:a.n]';
DAE.n = DAE.n + a.n;
a.dw = DAE.m + [1:a.n]';
DAE.m = DAE.m + a.n;
