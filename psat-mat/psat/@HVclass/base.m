function a = base(a)

global Bus Settings

if ~a.n, return, end

fm_errv(a.con(:,4),'Hvdc',a.bus1)
fm_errv(a.con(:,5),'Hvdc',a.bus2)

Vb2old = a.con(:,4).*a.con(:,4);
Vb2new = getkv(Bus,a.bus1,2);

k = Settings.mva*Vb2old./a.con(:,3)./Vb2new;
a.con(:,9) = k.*a.con(:,9);

Vb2old = a.con(:,5).*a.con(:,5);
Vb2new = getkv(Bus,a.bus2,2);

k = Settings.mva*Vb2old./a.con(:,3)./Vb2new;
a.con(:,10) = k.*a.con(:,10);
