function a = dynidx(a)

global DAE

if ~a.n, return, end

a.omega_t = zeros(a.n,1);
a.omega_m = zeros(a.n,1);
a.gamma = zeros(a.n,1);
a.e1r = zeros(a.n,1);
a.e1m = zeros(a.n,1);
for i = 1:a.n
  a.omega_t(i) = DAE.n + 1;
  a.omega_m(i) = DAE.n + 2;
  a.gamma(i) = DAE.n + 3;
  a.e1r(i) = DAE.n + 4;
  a.e1m(i) = DAE.n + 5;
  DAE.n = DAE.n + 5;
end
