function gcall_oxl(p)

global DAE Exc

if ~p.n, return, end

DAE.g = DAE.g - sparse(Exc.vref(p.exc),1,DAE.x(p.v),DAE.m,1);
DAE.g = DAE.g + sparse(p.If,1,ifield_oxl(p,1)-DAE.y(p.If),DAE.m,1);

