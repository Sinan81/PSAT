function Glcall(p)

global DAE

if ~p.n, return, end

jdx = find(p.u);
idx = p.bus(jdx);

if isempty(idx),return, end

DAE.Gl(idx) = DAE.Gl(idx) - p.pg(jdx);
