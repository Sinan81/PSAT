function Fxcall(p)

global DAE

if ~p.n, return, end

idx = p.vbus(find(p.u));

if isempty(idx),return, end

DAE.Fy(:,idx) = 0;
DAE.Gx(idx,:) = 0;
