function Glcall(a)

if ~a.n, return, end

global DAE

DAE.Gl(a.pm) = -a.pm0.*a.u;
DAE.Gk(a.pm) = -a.pm0.*a.u;
