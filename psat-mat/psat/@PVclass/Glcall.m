function Glcall(p)

global DAE

if ~p.n, return, end

DAE.Gl(p.bus) = DAE.Gl(p.bus) - p.u.*p.con(:,4);
