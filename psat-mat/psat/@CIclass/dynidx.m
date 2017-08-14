function a = dynidx(a)

global DAE Syn

if ~a.n, return, end

a.delta = zeros(a.n,1);
a.omega = zeros(a.n,1);

for i = 1:a.n
  a.delta(i) = DAE.m + 1;
  a.omega(i) = DAE.m + 2;
  DAE.m = DAE.m + 2;
end

a.dgen = Syn.delta(a.gen);
a.wgen = Syn.omega(a.gen);
