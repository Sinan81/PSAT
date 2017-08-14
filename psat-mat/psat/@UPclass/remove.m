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
a.vref(idx) = [];
a.Vref(idx) = [];
a.Cp(idx) = [];  
a.xcs(idx) = [];
a.vp(idx) = [];  
a.vq(idx) = [];  
a.iq(idx) = [];  
a.gamma(idx) = [];
a.vp0(idx) = [];
a.vq0(idx) = [];
a.Vp0(idx) = [];
a.Vq0(idx) = [];
