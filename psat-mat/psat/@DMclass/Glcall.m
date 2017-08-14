function Glcall(p)

global DAE

if ~p.n, return, end

DAE.Gl = DAE.Gl + sparse(p.bus,1,p.u.*p.con(:,3),DAE.m,1);
DAE.Gl = DAE.Gl + sparse(p.vbus,1,p.u.*p.con(:,4),DAE.m,1);

