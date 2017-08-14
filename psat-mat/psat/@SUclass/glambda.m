function glambda(p,lambda,kg)

global DAE

if ~p.n, return, end

DAE.g = DAE.g - sparse(p.bus,1,(lambda+kg*p.con(:,15)).*p.u.*p.con(:,3),DAE.m,1);
