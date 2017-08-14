function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.q(idx) = [];
a.q1(idx) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.u(idx) = [];
a.n = a.n - length(idx);
