function a = pvsum(a,idx,p)

if ~a.n, return, end
if isempty(idx), return, end
a.con(idx,4) = a.con(idx,4) + p;
