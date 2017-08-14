function idx = findbus_pq(a,bus)

idx = [];
if ~a.n, return, end
idx = find(a.u.*a.bus == bus);
