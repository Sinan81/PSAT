function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus1(idx) = [];
a.bus2(idx) = [];
a.v1(idx) = [];
a.v2(idx) = [];
a.n = a.n - length(idx);
a.alpha(idx,:) = [];
a.Pm(idx,:) = [];
a.u(idx) = [];
