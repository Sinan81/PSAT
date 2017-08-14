function a = dynidx(a)

global DAE

if ~a.n, return, end

a.x1 = zeros(a.n,1);
a.x2 = zeros(a.n,1);
a.x0 = zeros(a.n,1);
a.pref = zeros(a.n,1);

for i = 1:a.n
  a.x1(i) = DAE.n + 1;
  if a.con(i,3) == 2
    a.x2(i) = DAE.n + 2;
    DAE.n = DAE.n + 2;
  else
    DAE.n = DAE.n + 1;
  end
  a.x0(i) = DAE.m + 1;
  a.pref(i) = DAE.m + 2;
  DAE.m = DAE.m + 2;
end
