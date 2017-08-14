function idx = findzero(a)

idx = [];
if ~a.n, return, end
idx = find(a.con(:,3) == 0 & a.con(:,4) == 0 & a.u);
