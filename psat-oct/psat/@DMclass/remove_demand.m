function a = remove_demand(a,idx)

if ~a.n, return, end

if isempty(idx), return, end

a.u(idx) = 0;
