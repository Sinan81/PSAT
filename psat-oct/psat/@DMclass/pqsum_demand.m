function pqsum_demand(a,lambda)

global PQ

if ~a.n, return, end

tgd = tanphi_demand(a);

for i = 1:a.n
  idx = findbus_pq(PQ,a.bus(i));
  pd = lambda*a.u(i)*a.con(i,7);
  qd = lambda*a.u(i)*tgd(i)*a.con(i,7);
  PQ = pqsum_pq(PQ,idx,pd,qd);
end

