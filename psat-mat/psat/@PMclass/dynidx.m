function a = dynidx(a)

global DAE

if ~a.n, return, end

a.vm = zeros(a.n,1);
a.thetam = zeros(a.n,1);
for i = 1:a.n
  a.vm(i) = DAE.n + 1;
  a.thetam(i) = DAE.n + 2;
  DAE.n = DAE.n + 2;
end
