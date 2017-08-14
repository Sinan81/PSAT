function p = base(p)

global Settings

if ~p.n, return, end

p.con(:,6) = p.con(:,6).*p.con(:,2)/Settings.mva;
p.con(:,7) = p.con(:,7).*p.con(:,2)/Settings.mva;
p.con(:,8) = p.con(:,8).*p.con(:,2)/Settings.mva;
p.con(:,9) = p.con(:,9).*p.con(:,2)/Settings.mva;
