function a = dynidx(a)

global DAE

if ~a.n, return, end

a.mc = DAE.n + [1:a.n]';
DAE.n = DAE.n + a.n;

a.md = DAE.m + [1:a.n]';
DAE.m = DAE.m + a.n;
