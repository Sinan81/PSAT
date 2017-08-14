function a = dynidx(a)

global DAE Syn

if ~a.n, return, end

m = 8;
k = [0:m:m*(a.n-1)]';

a.delta_HP = DAE.n + 1 + k;
a.omega_HP = DAE.n + 2 + k;
a.delta_IP = DAE.n + 3 + k;
a.omega_IP = DAE.n + 4 + k;
a.delta_LP = DAE.n + 5 + k;
a.omega_LP = DAE.n + 6 + k;
a.delta_EX = DAE.n + 7 + k;
a.omega_EX = DAE.n + 8 + k;

DAE.n = DAE.n + m*a.n;

a.delta = Syn.delta(a.syn);
a.omega = Syn.omega(a.syn);
a.pm = Syn.pm(a.syn);
