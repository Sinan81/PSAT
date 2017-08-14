function glambda(a,lambda,kg)

if ~a.n, return, end

global DAE

DAE.g = DAE.g + sparse(a.pm,1,(1-lambda-kg)*a.pm0.*a.u,DAE.m,1);

