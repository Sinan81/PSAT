function idx = findbus_sw(a,bus)

idx = [];
if ~a.n, return, end
idx = find(a.bus.*a.u == bus);
