function a = setstatus_line(a,idx,u)

if ~a.n, return, end
if isempty(idx), return, end

a.u(idx) = u; 
a = build_y_line(a);
islands_line(a)
