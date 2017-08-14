function p = base(p)

global Settings

if ~p.n, return, end

p.con(:,3) = p.con(:,3).*p.con(:,2)/Settings.mva;
p.con(:,4) = p.con(:,4).*p.con(:,2)/Settings.mva;
p.con(:,5) = p.con(:,5).*p.con(:,2)/Settings.mva;
p.con(:,16) = p.con(:,16).*p.con(:,2)/Settings.mva;
p.con(:,17) = p.con(:,17).*p.con(:,2)/Settings.mva;
