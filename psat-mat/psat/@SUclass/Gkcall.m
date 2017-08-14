function Gkcall(p)

global DAE

if ~p.n, return, end

DAE.Gk = DAE.Gk - sparse(p.bus,1,p.u.*p.con(:,15).*p.con(:,3),DAE.m,1);
