function a = base(a)

global Bus Settings

if ~a.n, return, end

Vn = a.con(:,3);
Vb = getkv(Bus,a.bus,1);

fm_errv(Vn,'Subsynchronous Resonance Model',a.bus)

k = Settings.mva.*Vn.*Vn./a.con(:,2)./Vb./Vb;

a.con(:,5) = k.*a.con(:,5);
a.con(:,6) = k.*a.con(:,6);
a.con(:,7) = k.*a.con(:,7);
a.con(:,8) = k.*a.con(:,8);
a.con(:,9) = k.*a.con(:,9);
a.con(:,10) = k.*a.con(:,10);
a.con(:,11) = k.*a.con(:,11);
a.con(:,12) = k.*a.con(:,12);
a.con(:,13) = k.*a.con(:,13);

k = a.con(:,2)/Settings.mva;

a.con(:,14) = k.*a.con(:,14);
a.con(:,15) = k.*a.con(:,15);
a.con(:,16) = k.*a.con(:,16);
a.con(:,17) = k.*a.con(:,17);
a.con(:,18) = k.*a.con(:,18);
