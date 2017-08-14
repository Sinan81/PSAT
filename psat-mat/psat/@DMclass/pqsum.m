function pqsum(a,lambda)

global PQ

if ~a.n, return, end

tgd = tanphi(a);

for i = 1:a.n
  idx = findbus(PQ,a.bus(i));
  pd = lambda*a.u(i)*a.con(i,7);
  qd = lambda*a.u(i)*tgd(i)*a.con(i,7);
  PQ = pqsum(PQ,idx,pd,qd);
end

