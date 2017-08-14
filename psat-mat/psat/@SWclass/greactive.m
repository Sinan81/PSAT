function greactive(p)

global DAE

if ~p.n, return, end

idx = p.vbus(find(p.u));

if isempty(idx),return, end

DAE.g(idx) = 0;
