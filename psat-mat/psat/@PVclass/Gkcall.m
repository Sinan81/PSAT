function Gkcall(p)

global DAE

if ~p.n, return, end

DAE.Gk(p.bus) = DAE.Gk(p.bus) - p.u.*p.con(:,10).*p.con(:,4);
