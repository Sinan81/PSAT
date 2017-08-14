function a = dynidx(a)

global DAE

if ~a.n, return, end

a.theta_p = zeros(a.n,1);
a.omega_m = zeros(a.n,1);
a.idr = zeros(a.n,1);
a.iqr = zeros(a.n,1);
a.vref = zeros(a.n,1);
a.pwa = zeros(a.n,1);
for i = 1:a.n
  a.omega_m(i) = DAE.n + 1;
  a.theta_p(i) = DAE.n + 2;
  a.idr(i) = DAE.n + 3;
  a.iqr(i) = DAE.n + 4;
  DAE.n = DAE.n + 4;
  a.pwa(i) = DAE.m + 1;
  a.vref(i) = DAE.m + 2;
  DAE.m = DAE.m + 2;
end
