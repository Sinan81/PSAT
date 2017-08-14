function  b = busidx(a,bus_no)

if ~a.n, return, end
if isempty(bus_no), return, end

idx_fr = find(a.fr == bus_no);
idx_to = find(a.to == bus_no);

b = [a.fr(idx_to); a.to(idx_fr)];
