function Gyreactive_sw(p)

global DAE

if ~p.n, return, end

fm_setgy(p.vbus(find(p.u)));
