function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.n = a.n - length(idx);
a.x(idx) = [];
a.u(idx) = [];
a.dw(idx) = [];
a.a0(idx) = [];
