function idx = findgen_pq(a,bus)

idx = [];
if ~a.n, return, end
idx = find(double(a.bus).*double(a.gen) == bus);
