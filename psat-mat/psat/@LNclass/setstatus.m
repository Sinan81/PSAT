function a = setstatus(a,idx,u)

if ~a.n, return, end
if isempty(idx), return, end

a.u(idx) = u; 
a = build_y(a);
islands(a)
