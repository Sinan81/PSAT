function a = dynidx(a)

global DAE Syn Exc

if ~a.n, return, end

a.v = DAE.n+[1:a.n]';
a.If = DAE.m+[1:a.n]';
DAE.n = DAE.n + a.n;
DAE.m = DAE.m + a.n;

a.p = Syn.p(a.syn);
a.q = Syn.q(a.syn);
a.vref = Exc.vref(a.exc);
