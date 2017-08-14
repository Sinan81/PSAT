function p = base(p)

global Bus Settings

if ~p.n, return, end

fm_errv(p.con(:,3),'Synchronous Machine',p.bus);
Vb2new = getkv(Bus,p.bus,2);
Vb2old = p.con(:,3).*p.con(:,3);
k = Settings.mva*Vb2old./p.con(:,2)./Vb2new;
i = [6:10, 13:15];
for h = 1:length(i)
  p.con(:,i(h))= k.*p.con(:,i(h));
end
p.con(:,18) = p.con(:,18).*p.con(:,2)/Settings.mva;
p.con(:,19) = p.con(:,19).*p.con(:,2)/Settings.mva;
