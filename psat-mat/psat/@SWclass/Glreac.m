function Glreac(p)

global DAE

if ~p.n, return, end

idx = p.vbus(find(p.u));

if isempty(idx),return, end

DAE.Gl(idx) = 0;
