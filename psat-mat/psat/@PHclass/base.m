function p = base(p)

global Bus Settings

if ~p.n, return, end

V1 = getkv(Bus,p.bus1,1);
V2 = getkv(Bus,p.bus2,1);

VL1 = p.con(:,4);
VL2 = p.con(:,5);

fm_errv(VL1,'Phase Shifting Tranformer',p.bus1)
fm_errv(VL2,'Phase Shifting Tranformer',p.bus2)

Vb2new = V1.*V1;
Vb2old = VL1.*VL1;

p.con(:,10)  = p.con(:,10).*p.con(:,3)/Settings.mva;
p.con(:,11)  = Settings.mva*Vb2old.*p.con(:,11)./p.con(:,3)./Vb2new;
p.con(:,12)  = Settings.mva*Vb2old.*p.con(:,12)./p.con(:,3)./Vb2new;
