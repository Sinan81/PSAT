function [pmax,pmin] = plim_supply(a)

if ~a.n
  pmax = [];
  pmin = [];
  return
end

pmax = a.u.*a.con(:,4)+1e-8*(~a.u);
pmin = a.u.*a.con(:,5);
