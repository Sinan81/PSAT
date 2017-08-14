function a = dynidx(a)

global DAE

if ~a.n, return, end

a.bcv = zeros(a.n,1);
a.alpha = zeros(a.n,1);
a.vm = zeros(a.n,1);
a.vref = zeros(a.n,1);
a.q = zeros(a.n,1);

type = a.con(:,5);

for i = 1:a.n
  if type(i) == 1
    a.bcv(i) = DAE.n + 1;
    DAE.n = DAE.n + 1;
  elseif type(i) == 2
    a.alpha(i) = DAE.n + 1;
    a.vm(i) = DAE.n + 2;
    DAE.n = DAE.n + 2;
  end
  a.vref(i) = DAE.m + 1;
  a.q(i) = DAE.m + 2;
  DAE.m = DAE.m + 2;
end

a.bcv = a.bcv(find(a.bcv));
a.alpha = a.alpha(find(a.alpha));
a.vm = a.vm(find(a.vm));
a.Be = zeros(a.n,1);

