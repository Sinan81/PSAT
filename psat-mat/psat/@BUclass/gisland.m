function gisland(a)

global DAE

if isempty(a.island), return, end

kkk = a.island;
jjj = kkk+a.n;

DAE.g(kkk) = 0;
DAE.g(jjj) = 0;

DAE.y(kkk) = 0;
DAE.y(jjj) = 1e-6;
