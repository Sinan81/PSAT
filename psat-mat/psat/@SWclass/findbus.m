function idx = findbus(a,bus)

idx = [];
if ~a.n, return, end
idx = find(a.bus.*a.u == bus);
