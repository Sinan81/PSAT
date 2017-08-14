function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.n = a.n - length(idx);
a.btx1(idx) = [];
a.id(idx) = [];
a.iq(idx) = [];
a.vref(idx) = [];

a.u(idx) = [];
