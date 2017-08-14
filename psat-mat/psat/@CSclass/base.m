function p = base(p)

global Bus Settings

if ~p.n, return, end

fm_errv(p.con(:,4),'Cswt',p.bus)
Vb2old = p.con(:,4).*p.con(:,4);
Vb2new = getkv(Bus,p.bus,2);

k = Settings.mva*Vb2old./p.con(:,3)./Vb2new;

p.con(:,6) = k.*p.con(:,6);
p.con(:,7) = k.*p.con(:,7);
p.con(:,8) = k.*p.con(:,8);
p.con(:,9) = k.*p.con(:,9);
p.con(:,10) = k.*p.con(:,10);

k = p.con(:,3)/Settings.mva;

p.con(:,11) = p.con(:,11).*k;
p.con(:,12) = p.con(:,12).*k;
p.con(:,13) = p.con(:,13).*k;

