function pgsum(a,k)

global PV

if ~a.n, return, end

for i = 1:a.n
  idx = findbus(PV,a.bus(i));
  PV = pvsum(PV,idx,k*a.u(i)*a.con(i,6));
end

