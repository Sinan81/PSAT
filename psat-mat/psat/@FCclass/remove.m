function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.n = a.n - length(idx);
a.Ik(idx) = [];
a.Vk(idx) = [];
a.pH2(idx) = [];
a.pH2O(idx) = [];
a.pO2(idx) = [];
a.qH2(idx) = [];
a.m(idx) = [];
a.u(idx) = [];
