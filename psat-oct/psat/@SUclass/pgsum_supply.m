function pgsum_supply(a,k)

global PV

if ~a.n, return, end

for i = 1:a.n
  idx = findbus_pv(PV,a.bus(i));
  PV = pvsum_pv(PV,idx,k*a.u(i)*a.con(i,6));
end

