function p = base(p)

global Settings Dfig

if ~p.n, return, end

Sn = Dfig.con(p.gen, 3);

p.con(:, 13) = p.con(:, 13).*Sn/Settings.mva;
p.con(:, 14) = p.con(:, 14).*Sn/Settings.mva;
