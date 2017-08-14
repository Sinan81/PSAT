function a = dynidx(a)

global DAE

if ~a.n, return, end

a.btx1 = zeros(a.n,1);
a.id = zeros(a.n,1);
a.iq = zeros(a.n,1);
a.vref = zeros(a.n,1);

for i = 1:a.n
  a.btx1(i) = DAE.n + 1;
  a.id(i) = DAE.n + 2;
  a.iq(i) = DAE.n + 3;
  DAE.n = DAE.n + 3;
  a.vref(i) = DAE.m + 1;
  DAE.m = DAE.m + 1;
end
