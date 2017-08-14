function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.dat(idx) = [];
a.n = a.n - length(idx);
a.vm(idx,:) = [];
a.thetam(idx,:) = [];
a.u(idx) = [];
