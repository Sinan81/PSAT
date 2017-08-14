function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.syn(idx) = [];
a.n = a.n - length(idx);
a.delta_HP(idx) = [];
a.omega_HP(idx) = [];
a.delta_IP(idx) = [];
a.omega_IP(idx) = [];
a.delta_LP(idx) = [];
a.omega_LP(idx) = [];
a.delta_EX(idx) = [];
a.omega_EX(idx) = [];
a.delta(idx) = [];
a.omega(idx) = [];
a.pm(idx) = [];
a.u(idx) = [];
