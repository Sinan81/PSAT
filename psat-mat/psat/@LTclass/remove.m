function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.bus1(idx) = [];
a.bus2(idx) = [];
a.v1(idx) = [];
a.v2(idx) = [];
a.vr(idx) = [];
a.n = a.n - length(idx);
a.mc(idx) = [];
a.md(idx) = [];
a.mold(idx) = []; 
a.delay(idx) = []; 
a.u(idx) = [];
