function gcall(a)

global DAE

if ~a.n, return, end

DAE.g(a.ws) = DAE.lambda*wspeed(a)-DAE.y(a.ws);
