function [pmax,pmin] = plim_rsrv(a)

if ~a.n
  pmax = [];
  pmin = [];
  return
end

pmax = a.u.*a.con(:,3) + 1e-8*(~a.u);
pmin = a.u.*a.con(:,4);
