function a = remove_thload(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.n = a.n - length(idx);
a.T(idx) = [];
a.x(idx) = [];
a.G(idx) = [];
a.u(idx) = [];
