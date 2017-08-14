function glambda_tg(p,lambda,kg)

global DAE

if ~p.n, return, end

DAE.g = DAE.g - sparse(p.pm,1,(kg+lambda-1)*p.u.*pmech_tg(p),DAE.m,1);
