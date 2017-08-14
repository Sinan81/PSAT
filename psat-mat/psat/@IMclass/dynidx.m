function a = dynidx(a)

global DAE

if ~a.n, return, end

a.slip = zeros(a.n,1);
a.e1r = zeros(a.n,1);
a.e1m = zeros(a.n,1);
a.e2r = zeros(a.n,1);
a.e2m = zeros(a.n,1);

for i = 1:a.n
  mot_ord = a.con(i,5);
  switch mot_ord
   case 1
    a.slip(i) = DAE.n + 1;
    DAE.n = DAE.n+1;
   case 3
    a.slip(i) = DAE.n + 1;
    a.e1r(i) = DAE.n + 2;
    a.e1m(i) = DAE.n + 3;
    DAE.n = DAE.n+3;
   case 5
    a.slip(i) = DAE.n + 1;
    a.e1r(i) = DAE.n + 2;
    a.e1m(i) = DAE.n + 3;
    a.e2r(i) = DAE.n + 4;
    a.e2m(i) = DAE.n + 5;
    DAE.n = DAE.n+5;
  end
end
