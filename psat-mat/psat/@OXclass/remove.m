function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.exc(idx) = [];
a.v(idx) = [];
a.p(idx) = [];
a.q(idx) = [];
a.vref(idx) = [];
a.If(idx) = [];
a.u(idx) = [];
a.n = a.n - length(idx);
