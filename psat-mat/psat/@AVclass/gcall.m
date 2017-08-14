function gcall(p)

global DAE

if ~p.n, return, end

DAE.g = DAE.g + sparse(p.vfd,1,DAE.x(p.vf),DAE.m,1);
DAE.g = DAE.g + sparse(p.vref,1,p.u.*p.vref0-DAE.y(p.vref),DAE.m,1);
