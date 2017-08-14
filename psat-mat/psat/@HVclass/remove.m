function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.dat(idx,:) = [];
a.bus1(idx) = [];
a.bus2(idx) = [];
a.v1(idx) = [];
a.v2(idx) = [];
a.n = a.n - length(idx);
a.Idc(idx) = [];
a.xr(idx) = [];
a.xi(idx) = [];
a.cosa(idx) = [];  
a.cos(idx)g = []; 
a.phir(idx) = [];  
a.phii(idx) = [];
a.Vrdc(idx) = [];
a.Vidc(idx) = [];
a.yr(idx) = [];   
a.yi(idx) = []; 
a.u(idx) = [];
