function xfirst(a)

global DAE

if ~a.n, return, end

DAE.x(a.mc) = ones(a.n,1);
DAE.y(a.md) = ones(a.n,1);
