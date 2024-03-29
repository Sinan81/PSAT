function p = base_sw(p)

global Bus Settings

if ~p.n, return, end

fm_errv(p.con(:,3),'Slack Bus',p.bus);
Vb = getkv_bus(Bus,p.bus,1);
p.con(:,6) = p.con(:,6).*p.con(:,2)/Settings.mva;
p.con(:,7) = p.con(:,7).*p.con(:,2)/Settings.mva;
p.con(:,8) = p.con(:,8).*p.con(:,3)./Vb;
p.con(:,9) = p.con(:,9).*p.con(:,3)./Vb;
p.con(:,10) = p.con(:,10).*p.con(:,2)/Settings.mva;
p.pg = p.con(:,10);
