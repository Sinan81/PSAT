function Glcall(p)

global DAE

if ~p.n, return, end

DAE.Gl(p.bus) = DAE.Gl(p.bus) + p.u.*p.con(:,4);
DAE.Gl(p.vbus) = DAE.Gl(p.vbus) + p.u.*p.con(:,5);
