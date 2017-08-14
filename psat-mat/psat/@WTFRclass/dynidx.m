function a = dynidx(a)

global DAE Dfig Busfreq

if ~a.n, return, end

a.Dfm = zeros(a.n,1);
a.x = zeros(a.n,1);
a.csi = zeros(a.n,1);
a.pfw = zeros(a.n,1);
a.pf1 = zeros(a.n, 1);
a.pwa = zeros(a.n, 1);

for i = 1:a.n
  a.Dfm(i) = DAE.n + 1;
  a.x(i) = DAE.n + 2;
  a.csi(i) = DAE.n + 3;
  a.pfw(i) = DAE.n + 4;
  DAE.n = DAE.n + 4;
  a.pf1(i) = DAE.m + 1;
  a.pwa(i) = DAE.m + 2;
  DAE.m = DAE.m + 2;
end

a.pout = Dfig.pwa(a.gen);
a.we = Dfig.omega_m(a.gen);
a.Df = Busfreq.w(a.freq);
