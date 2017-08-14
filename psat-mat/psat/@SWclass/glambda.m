function glambda(p,lambda,kg)

global DAE

if ~p.n, return, end

jdx = find(p.u);
idx = p.bus(jdx);

if isempty(idx),return, end

DAE.g(idx) = DAE.g(idx) - (lambda+kg*p.con(jdx,11)).*p.pg(jdx);

