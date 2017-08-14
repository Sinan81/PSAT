function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.exc(idx) = [];
a.syn(idx) = [];
a.va(idx) = [];
a.v1(idx) = [];
a.v2(idx) = [];
a.v3(idx) = [];
a.vss(idx) = [];
a.u(idx) = [];
a.s1(idx) = [];
a.omega(idx) = [];
a.p(idx) = [];
a.vf(idx) = [];
a.vref(idx) = [];
a.n = a.n - length(idx);
