function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.wind(idx) = [];
a.n = a.n - length(idx);
a.omega_t(idx,:) = [];
a.omega_m(idx,:) = [];
a.e1r(idx,:) = [];
a.e1m(idx,:) = [];
a.gamma(idx,:) = [];
a.u(idx) = [];
