function Gkcall(p)

global DAE

if ~p.n, return, end

jdx = find(p.u);
idx = p.bus(jdx);

if isempty(idx),return, end

DAE.Gk(idx) = DAE.Gk(idx) - p.con(jdx,11).*p.pg(jdx);
