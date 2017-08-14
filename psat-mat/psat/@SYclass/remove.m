function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.n = a.n - length(idx);
a.bus(idx,:) = [];
a.vbus(idx,:) = [];
a.Id(idx,:) = [];
a.Iq(idx,:) = [];
a.J11(idx,:) = [];
a.J12(idx,:) = [];
a.J2(idx,:)1 = [];
a.J22(idx,:) = [];
a.delta(idx,:) = [];
a.omega(idx,:) = [];
a.e1q(idx,:) = [];
a.e1d(idx,:) = [];
a.e2q(idx,:) = [];
a.e2d(idx,:) = [];
a.psiq(idx,:) = [];
a.psid(idx,:) = [];
a.pm(idx,:) = [];
a.vf(idx,:) = [];
a.p(idx,:) = [];
a.q(idx,:) = [];
a.pm0(idx,:) = [];
a.vf0(idx,:) = [];
a.Pg0(idx,:) = [];
a.c1(idx,:) = [];
a.c2(idx,:) = [];
a.c3(idx,:) = [];
a.u(idx,:) = [];
