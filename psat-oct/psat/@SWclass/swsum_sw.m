function a = swsum_sw(a,idx,p)

if ~a.n, return, end
if isempty(idx), return, end
a.pg(idx) = a.u(idx).*(a.pg(idx) + p);
