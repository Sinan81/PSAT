function p = base(p)

global Bus Settings

if ~p.n, return, end

fm_errv(p.con(:,3),'PQ Bus',p.bus);
Vb = getkv(Bus,p.bus,1);
p.con(:,4) = p.con(:,4).*p.con(:,2)/Settings.mva;
p.con(:,5) = p.con(:,5).*p.con(:,2)/Settings.mva;
p.con(:,6) = p.con(:,6).*p.con(:,3)./Vb;
p.con(:,7) = p.con(:,7).*p.con(:,3)./Vb;
p.P0 = p.u.*p.con(:,4);
p.Q0 = p.u.*p.con(:,5);
