function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.syn(idx) = [];
a.vref(idx) = [];
a.vref0(idx) = [];
a.vr1(idx) = [];
a.vr2(idx) = [];
a.vr3(idx) = [];
a.vfd(idx) = [];
a.vm(idx) = [];
a.vf(idx) = [];
a.u(idx) = [];
a.n = a.n - length(idx);
