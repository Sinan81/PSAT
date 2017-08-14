function p = base(p)

global Syn Settings

if ~p.n, return, end

mva = getvar(Syn,p.syn,'mva');

p.con(:,2) = Settings.mva*p.con(:,2)./mva;
p.con(:,3) = Settings.mva*p.con(:,3)./mva;
p.con(:,4) = Settings.mva*p.con(:,4)./mva;
p.con(:,5) = Settings.mva*p.con(:,5)./mva;

p.con(:,6) = mva.*p.con(:,6)/Settings.mva;
p.con(:,7) = mva.*p.con(:,7)/Settings.mva;
p.con(:,8) = mva.*p.con(:,8)/Settings.mva;
p.con(:,9) = mva.*p.con(:,9)/Settings.mva;

p.con(:,10) = mva.*p.con(:,10)/Settings.mva;
p.con(:,11) = mva.*p.con(:,11)/Settings.mva;
p.con(:,12) = mva.*p.con(:,12)/Settings.mva;
p.con(:,13) = mva.*p.con(:,13)/Settings.mva;

p.con(:,14) = mva.*p.con(:,14)/Settings.mva;
p.con(:,15) = mva.*p.con(:,15)/Settings.mva;
p.con(:,16) = mva.*p.con(:,16)/Settings.mva;
p.con(:,17) = mva.*p.con(:,17)/Settings.mva;

p.con(:,18) = Settings.mva*p.con(:,18)./mva;
