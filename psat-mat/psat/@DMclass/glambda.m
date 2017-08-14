function glambda(p,lambda)

global DAE

if ~p.n, return, end

DAE.g = DAE.g + sparse(p.bus,1,lambda*p.u.*p.con(:,3),DAE.m,1) ...
        + sparse(p.vbus,1,lambda*p.u.*p.con(:,4),DAE.m,1);
