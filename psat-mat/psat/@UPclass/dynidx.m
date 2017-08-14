function a = dynidx(a)

global DAE

if ~a.n, return, end

a.vp = zeros(a.n,1);
a.vq = zeros(a.n,1);
a.iq = zeros(a.n,1);
a.vp0 = zeros(a.n,1);
a.vq0 = zeros(a.n,1);
a.vref = zeros(a.n,1);

for i = 1:a.n
  a.vp(i) = DAE.n + 1;
  a.vq(i) = DAE.n + 2;     
  a.iq(i) = DAE.n + 3;
  DAE.n = DAE.n + 3;
  a.vp0(i) = DAE.m + 1;
  a.vq0(i) = DAE.m + 2;     
  a.vref(i) = DAE.m + 3;
  DAE.m = DAE.m + 3;
end

a.gamma = zeros(a.n,1);
