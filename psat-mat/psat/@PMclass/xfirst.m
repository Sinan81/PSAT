function xfirst(a)

global DAE

if ~a.n, return, end

DAE.x(a.vm) = ones(a.n,1);
DAE.x(a.thetam) = zeros(a.n,1);
