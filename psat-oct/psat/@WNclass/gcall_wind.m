function gcall_wind(a)

global DAE

if ~a.n, return, end

DAE.g(a.ws) = DAE.lambda*wspeed_wind(a)-DAE.y(a.ws);
