function a = dynidx(a)

global DAE

if ~a.n, return, end

a.delta = zeros(a.n,1);
a.omega = zeros(a.n,1);
a.e1q = zeros(a.n,1);
a.e1d = zeros(a.n,1);
a.e2q = zeros(a.n,1);
a.e2d = zeros(a.n,1);
a.psiq = zeros(a.n,1);
a.psid = zeros(a.n,1);
a.pm = zeros(a.n,1);
a.vf = zeros(a.n,1);
a.p = zeros(a.n,1);
a.q = zeros(a.n,1);

for i = 1:a.n
  a.delta(i) = DAE.n + 1;
  a.omega(i) = DAE.n + 2;
  a.vf(i) = DAE.m + 1;
  a.pm(i) = DAE.m + 2;
  a.p(i) = DAE.m + 3;
  a.q(i) = DAE.m + 4;
  DAE.m = DAE.m + 4;
  syn_ord = a.con(i,5);
  switch syn_ord
   case 2
    DAE.n = DAE.n+2;
   case 3
    a.e1q(i) =   DAE.n + 3;
    DAE.n = DAE.n+3;
   case 4
    a.e1q(i) =   DAE.n + 3;
    a.e1d(i) =   DAE.n + 4;
    DAE.n = DAE.n+4;
   case 5
    a.con(i,5) = 5.1;
    a.e1q(i) =   DAE.n + 3;
    a.e1d(i) =   DAE.n + 4;
    a.e2d(i) =   DAE.n + 5;
    DAE.n = DAE.n+5;
   case 5.1
    a.e1q(i) =   DAE.n + 3;
    a.e1d(i) =   DAE.n + 4;
    a.e2d(i) =   DAE.n + 5;
    DAE.n = DAE.n+5;
   case 5.2
    a.e1q(i) =   DAE.n + 3;
    a.e2q(i) =   DAE.n + 4;
    a.e2d(i) =   DAE.n + 5;
    DAE.n = DAE.n+5;
   case 5.3
    a.e1q(i) =   DAE.n + 3;
    a.psid(i) =   DAE.n + 4;
    a.psiq(i) =   DAE.n + 5;
    DAE.n = DAE.n+5;
   case 6
    a.e1q(i) =   DAE.n + 3;
    a.e1d(i) =   DAE.n + 4;
    a.e2q(i) =   DAE.n + 5;
    a.e2d(i) =   DAE.n + 6;
    DAE.n = DAE.n+6;
   case 8
    a.e1q(i)   = DAE.n + 3;
    a.e1d(i)   = DAE.n + 4;
    a.e2q(i)   = DAE.n + 5;
    a.e2d(i)   = DAE.n + 6;
    a.psiq(i)  = DAE.n + 7;
    a.psid(i)  = DAE.n + 8;
    DAE.n = DAE.n+8;
  end
end
