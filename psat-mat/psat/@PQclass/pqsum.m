function a = pqsum(a,idx,p,q)

if ~a.n, return, end
if isempty(idx), return, end
a.con(idx,4) = a.con(idx,4) + p;
a.con(idx,5) = a.con(idx,5) + q;
