function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.line(idx) = [];
a.bus1(idx) = [];
a.bus2(idx) = [];
a.v1(idx) = [];
a.v2(idx) = [];
a.n = a.n - length(idx);
a.y(idx) = [];
a.u(idx) = [];
a.pref(idx) = [];
a.Pref(idx) = [];
a.Cp(idx) = [];  
a.xcs(idx) = [];
a.vcs(idx) = [];  
a.vpi(idx) = [];  
a.v0(idx) = [];
a.V0(idx) = [];
