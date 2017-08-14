function a = dynidx(a)

global DAE

if ~a.n, return, end

m = 15;
k = [0:m:m*(a.n-1)]';

a.Id = DAE.n + 1 + k;
a.Iq = DAE.n + 2 + k;
a.If = DAE.n + 3 + k;
a.Edc = DAE.n + 4 + k;
a.Eqc = DAE.n + 5 + k;
a.delta_HP = DAE.n + 6 + k;
a.omega_HP = DAE.n + 7 + k;
a.delta_IP = DAE.n + 8 + k;
a.omega_IP = DAE.n + 9 + k;
a.delta_LP = DAE.n + 10 + k;
a.omega_LP = DAE.n + 11 + k;
a.delta = DAE.n + 12 + k;
a.omega = DAE.n + 13 + k;
a.delta_EX = DAE.n + 14 + k;
a.omega_EX = DAE.n + 15 + k;

DAE.n = DAE.n + m*a.n;
