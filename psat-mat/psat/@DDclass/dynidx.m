function a = dynidx(a)

global DAE

if ~a.n, return, end

a.theta_p = zeros(a.n,1);
a.omega_m = zeros(a.n,1);
a.iqs = zeros(a.n,1);
a.ids = zeros(a.n,1);
a.iqc = zeros(a.n,1);
a.pwa = zeros(a.n,1);
for i = 1:a.n
  a.omega_m(i) = DAE.n + 1;
  a.theta_p(i) = DAE.n + 2;
  a.iqs(i) = DAE.n + 3;
  a.idc(i) = DAE.n + 4;
  DAE.n = DAE.n + 4;
  a.ids(i) = DAE.m + 1;
  a.iqc(i) = DAE.m + 2;
  a.pwa(i) = DAE.m + 3; 
  DAE.m = DAE.m + 3;
end
