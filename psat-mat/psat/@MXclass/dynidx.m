function a = dynidx(a)

global DAE

if ~a.n, return, end

a.x = zeros(a.n,1);
a.y = zeros(a.n,1);
for i = 1:a.n
  a.x(i) = DAE.n + 1;
  a.y(i) = DAE.n + 2;
  DAE.n = DAE.n + 2;
end
