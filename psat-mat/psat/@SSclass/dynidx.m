function a = dynidx(a)

global DAE

if ~a.n, return, end

a.vcs = zeros(a.n,1);  
a.vpi = zeros(a.n,1);  
a.v0 = zeros(a.n,1);
a.pref = zeros(a.n,1);

for i = 1:a.n
  if a.con(i,2) == 3
    a.vcs(i,1) = DAE.n + 1;
    a.vpi(i,1) = DAE.n + 2;
    DAE.n = DAE.n + 2;
  else
    a.vcs(i,1) = DAE.n + 1;
    DAE.n = DAE.n + 1;
  end
  a.v0(i) = DAE.m + 1;
  a.pref(i) = DAE.m + 2;
  DAE.m = DAE.m + 2;
end

