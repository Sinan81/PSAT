function a = dynidx_cac(a)

global DAE

if ~a.n, return, end

a.q1 = DAE.n + [1:a.n]';
DAE.n = DAE.n + a.n;
a.q = DAE.m + [1:a.n]';
DAE.m = DAE.m + a.n;
