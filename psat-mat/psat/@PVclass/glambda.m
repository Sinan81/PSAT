function glambda(p,lambda,kg)

global DAE

if ~p.n, return, end

DAE.g(p.bus) = DAE.g(p.bus) - p.u.*(lambda+kg*p.con(:,10)).*p.con(:,4);
