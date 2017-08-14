function a = remove(a,idx)

if isempty(idx), return, end

a.n = a.n - length(idx);
a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.u(idx) = [];
