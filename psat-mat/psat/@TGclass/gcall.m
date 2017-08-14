function gcall(p)
% computes algebraic equations g
global DAE

if ~p.n, return, end

DAE.g = DAE.g ...
    + sparse(p.pm,1,p.u.*pmech(p),DAE.m,1) ...
    + sparse(p.wref,1,p.u.*p.con(:,3)-DAE.y(p.wref),DAE.m,1);
