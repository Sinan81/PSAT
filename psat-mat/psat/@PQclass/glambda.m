function glambda(p,lambda)

global DAE

if ~p.n, return, end

DAE.g(p.bus) = lambda*p.con(:,4).*p.u + DAE.g(p.bus);
DAE.g(p.vbus) = lambda*p.con(:,5).*p.u + DAE.g(p.vbus);
