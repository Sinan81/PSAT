function gcall(p)

global DAE

if ~p.n, return, end

DAE.g = DAE.g + sparse(p.vref,1,p.u.*DAE.x(p.Vs),DAE.m,1);
