function a = dynidx(a)

global DAE Exc Svc Cac Syn

if ~a.n, return, end

a.Vs = DAE.n + [1:a.n]';
DAE.n = DAE.n + a.n;

a.vref = zeros(a.n,1);
a.vref(a.exc) = Exc.vref(a.con(a.exc,2));
a.vref(a.svc) = Svc.vref(a.con(a.svc,2));

a.cac = Cac.q(a.con(:,1));

a.q = zeros(a.n,1);
a.q(a.exc) = Syn.q(a.syn);
a.q(a.svc) = Svc.q(a.con(a.svc,2));

