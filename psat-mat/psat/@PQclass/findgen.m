function idx = findgen(a,bus)

idx = [];
if ~a.n, return, end
idx = find(double(a.bus).*double(a.gen) == bus);
