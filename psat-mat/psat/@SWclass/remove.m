function a = remove(a,k)

if ~a.n, return, end
if isempty(k), return, end

a.con(k,:) = [];
a.bus(k) = [];
a.vbus(k) = [];
a.u(k) = [];
a.pg(k) = [];
a.qg(k) = [];
a.dq(k) = [];
a.n = a.n - length(k);
a.qmax(k) = [];
a.qmin(k) = [];
