function a = dynidx(a)

global DAE

if ~a.n, return, end

a.xp = zeros(a.n,1);
a.xq = zeros(a.n,1);
for i = 1:a.n
  a.xp(i) = DAE.n + 1;
  a.xq(i) = DAE.n + 2;
  DAE.n = DAE.n + 2;
end
