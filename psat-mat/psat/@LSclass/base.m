function p = base(p)

global Bus Settings

if ~p.n, return, end

V1 = getkv(Bus,p.bus1,1);
V2 = getkv(Bus,p.bus2,1);

Vrate = p.con(:,4);

fm_errv(Vrate,'Transmission Line',p.bus1)
fm_errv(Vrate,'Transmission Line',p.bus2)

Vb2new = V1.*V1;
Vb2old = Vrate.*Vrate;

p.con(:,6)  = Settings.mva*Vb2old.*p.con(:,6)./p.con(:,3)./Vb2new;
p.con(:,7)  = Settings.mva*Vb2old.*p.con(:,7)./p.con(:,3)./Vb2new;
p.con(:,8)  = Vb2new.*p.con(:,7).*p.con(:,3)./Vb2old/Settings.mva;
