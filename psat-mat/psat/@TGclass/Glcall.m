function Glcall(p)

global DAE

if ~p.n, return, end

DAE.Gl = DAE.Gl - sparse(p.pm,1,p.u.*pmech(p),DAE.m,1);
DAE.Gk = DAE.Gk - sparse(p.pm,1,p.u.*pmech(p),DAE.m,1);
