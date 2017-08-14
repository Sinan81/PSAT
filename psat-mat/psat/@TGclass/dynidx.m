function a = dynidx(a)
% assigns indexes to the state variables
global DAE Syn

if ~a.n, return, end

a.ty1 = find(a.con(:,2) == 1);
a.ty2 = find(a.con(:,2) == 2);
a.ty3 = find(a.con(:,2) == 3);
a.ty4 = find(a.con(:,2) == 4);
a.ty5 = find(a.con(:,2) == 5);
a.ty6 = find(a.con(:,2) == 6);
a.tg1 = zeros(a.n,1);
a.tg2 = zeros(a.n,1);
a.tg3 = zeros(a.n,1);
a.tg4 = zeros(a.n,1);
a.tg5 = zeros(a.n,1);
a.tg  = zeros(a.n,1);

for i = 1:a.n
  switch a.con(i,2)
   case 1
    a.tg1(i) = DAE.n + 1;
    a.tg2(i) = DAE.n + 2;
    a.tg3(i) = DAE.n + 3;
    DAE.n = DAE.n + 3;
   case 2
    a.tg(i) = DAE.n + 1;
    DAE.n = DAE.n + 1;
   case 3
    a.tg1(i) = DAE.n + 1;
    a.tg2(i) = DAE.n + 2;
    a.tg3(i) = DAE.n + 3;
    a.tg4(i) = DAE.n + 4;
    DAE.n = DAE.n + 4; 
   case 4
    a.tg1(i) = DAE.n + 1;
    a.tg2(i) = DAE.n + 2;
    a.tg3(i) = DAE.n + 3;
    a.tg4(i) = DAE.n + 4;
    a.tg5(i) = DAE.n + 5;
    DAE.n = DAE.n + 5;
   case 5
    a.tg1(i) = DAE.n + 1;
    a.tg2(i) = DAE.n + 2;
    a.tg3(i) = DAE.n + 3;
    a.tg4(i) = DAE.n + 4;
    DAE.n = DAE.n + 4; 
   case 6
    a.tg1(i) = DAE.n + 1;
    a.tg2(i) = DAE.n + 2;
    a.tg3(i) = DAE.n + 3;
    a.tg4(i) = DAE.n + 4;
    a.tg5(i) = DAE.n + 5;
    DAE.n = DAE.n + 5;
  end
end

a.wref = DAE.m + [1:a.n]';
DAE.m = DAE.m + a.n;

a.pm = Syn.pm(a.syn);
