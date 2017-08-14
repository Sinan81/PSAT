function a = dynidx(a)

global DAE

if ~a.n, return, end

a.id = zeros(a.n,1);
a.iq = zeros(a.n,1);
for i = 1:a.n
  a.id(i) = DAE.n + 1;
  a.iq(i) = DAE.n + 2;
  DAE.n = DAE.n + 2;
end
