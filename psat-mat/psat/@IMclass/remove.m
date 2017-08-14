function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.n = a.n - length(idx);
a.slip(idx) = [];
a.e1r(idx) = [];
a.e1m(idx) = [];
a.e2r(idx) = [];
a.e2m(idx) = [];
a.u(idx) = [];
a.z(idx) = [];
a.dat(idx,:) = [];
