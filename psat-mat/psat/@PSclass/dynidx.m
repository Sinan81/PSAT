function a = dynidx(a)

global DAE Syn Exc

if ~a.n, return, end

a.v1 = zeros(a.n,1);
a.v2 = zeros(a.n,1);
a.v3 = zeros(a.n,1);
a.va = zeros(a.n,1);

a.vss = DAE.m + [1:a.n]';
DAE.m = DAE.m + a.n;

for i = 1:a.n
  switch a.con(i,2)
   case 1
    a.v1(i) = DAE.n + 1;
    DAE.n = DAE.n + 1;
   case {2,3}
    a.v1(i) = DAE.n + 1;
    a.v2(i) = DAE.n + 2;
    a.v3(i) = DAE.n + 3;
    DAE.n = DAE.n + 3;
   case {4,5}
    a.v1(i) = DAE.n + 1;
    a.v2(i) = DAE.n + 2;
    a.v3(i) = DAE.n + 3;
    a.va(i) = DAE.n + 4;
    DAE.n = DAE.n + 4;
  end
end

a.s1 = zeros(a.n,1);
a.omega = Syn.omega(a.syn);
a.p = Syn.p(a.syn);
a.vf = Syn.vf(a.syn);
a.vref = Exc.vref(a.exc);
