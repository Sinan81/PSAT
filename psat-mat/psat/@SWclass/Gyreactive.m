function Gyreactive(p)

global DAE

if ~p.n, return, end

fm_setgy(p.vbus(find(p.u)));
