function Gyisland(a)

global DAE

if isempty(a.island), return, end

fm_setgy(a.island);
fm_setgy(a.island+a.n);
