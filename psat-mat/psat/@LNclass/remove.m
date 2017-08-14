function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.fr(idx) = [];
a.to(idx) = [];
a.vfr(idx) = [];
a.vto(idx) = [];
a.u(idx) = []; 
a.n = a.n - length(idx);
