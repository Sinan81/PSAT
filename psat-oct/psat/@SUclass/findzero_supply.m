function idx = findzero_supply(a)

idx = [];
if ~a.n, return, end
idx = find(a.u.*a.con(:,3) == 0);
