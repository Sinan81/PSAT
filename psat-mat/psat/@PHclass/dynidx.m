function a = dynidx(a)

global DAE

if ~a.n, return, end

for i = 1:a.n
  a.alpha(i) = DAE.n + 1;
  a.Pm(i) = DAE.n + 2;
  DAE.n = DAE.n + 2;
end
