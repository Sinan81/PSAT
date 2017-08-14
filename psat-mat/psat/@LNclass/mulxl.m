function a = mulxl(a,idx,val)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,9) = a.con(idx,9).*val; 

