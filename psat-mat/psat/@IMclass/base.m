function a = base(a)

if ~a.n, return, end

global Settings Bus

fm_errv(a.con(:,3),'Induction Machine',a.bus);

Vb2new = getkv(Bus,a.bus,2);
Vb2old = a.con(:,3).*a.con(:,3);

k = Settings.mva*Vb2old./a.con(:,2)./Vb2new;

a.con(:,7)  = k.*a.con(:,7);
a.con(:,8)  = k.*a.con(:,8);
a.con(:,9)  = k.*a.con(:,9);
a.con(:,10) = k.*a.con(:,10);
a.con(:,11) = k.*a.con(:,11);
a.con(:,12) = k.*a.con(:,12);
a.con(:,13) = k.*a.con(:,13);

k = a.con(:,2)/Settings.mva;

a.con(:,14) = a.con(:,14).*k;
a.con(:,15) = a.con(:,15).*k;
a.con(:,16) = a.con(:,16).*k;
a.con(:,17) = a.con(:,17).*k;

% update a.dat matrix.
a = setdat(a);
