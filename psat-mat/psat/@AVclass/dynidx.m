function a = dynidx(a)

global DAE Syn

if ~a.n, return, end

a.vm  = zeros(a.n,1);
a.vr1 = zeros(a.n,1);
a.vr2 = zeros(a.n,1);
a.vr3 = zeros(a.n,1);
a.vf = zeros(a.n,1);
a.vfd = Syn.vf(a.syn);

a.vref0 = ones(a.n,1);
a.vref  = DAE.m + [1:a.n]';
DAE.m = DAE.m + a.n;

for i = 1:a.n
  switch a.con(i,2)
   case 1
    a.vm(i)  = DAE.n + 1;
    a.vr1(i) = DAE.n + 2;
    a.vr2(i) = DAE.n + 3;
    a.vf(i) = DAE.n + 4;
    DAE.n = DAE.n + 4;
   case 2
    a.vm(i)  = DAE.n + 1;
    a.vr1(i) = DAE.n + 2;
    a.vr2(i) = DAE.n + 3;
    a.vf(i) = DAE.n + 4;
    DAE.n = DAE.n + 4;
   case 3
    a.vm(i)  = DAE.n + 1;
    a.vr3(i) = DAE.n + 2;
    a.vf(i) = DAE.n + 3;
    DAE.n = DAE.n + 3;
  end
end
