function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.q(idx) = [];
a.cac(idx) = [];
a.exc(idx) = [];
a.syn(idx) = [];
a.svc(idx) = [];
a.vref(idx) = [];
a.dVsdQ(idx) = [];
a.Vs(idx) = [];
a.u(idx) = [];
a.n = a.n - length(idx);
