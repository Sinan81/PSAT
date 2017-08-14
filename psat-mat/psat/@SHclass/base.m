function a = base(a)

if ~a.n, return, end

global Bus Settings

fm_errv(a.con(:,3),'Shunt',a.bus);
Vb2new = getkv(Bus,a.bus,2);
Vb2old = a.con(:,3).*a.con(:,3);
a.con(:,5) = a.con(:,2).*Vb2new.*a.con(:,5)./Vb2old/Settings.mva;
a.con(:,6) = a.con(:,2).*Vb2new.*a.con(:,6)./Vb2old/Settings.mva;
