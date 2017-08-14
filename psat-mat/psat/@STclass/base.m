function p = base(p)

global Bus Settings

if ~p.n, return, end

fm_errv(p.con(:,3),'Statcom',p.bus)

Iold = p.con(:,2)./p.con(:,3);
Inew = Settings.mva./getkv(Bus,p.bus,1);

p.con(:,7) = p.con(:,7).*Iold./Inew;
p.con(:,8) = p.con(:,8).*Iold./Inew;

