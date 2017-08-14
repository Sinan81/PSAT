function a = dynidx(a)

global DAE

if ~a.n, return, end

a.vw = DAE.n + [1:a.n]';
DAE.n = DAE.n + a.n;
a.ws = DAE.m + [1:a.n]';
DAE.m = DAE.m + a.n;
