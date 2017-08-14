function p = base(p)

global Bus Settings

if ~p.n, return, end

fm_errv(p.con(:,3),'Svc',p.bus)
Vb = getkv(Bus,p.bus,1);
Vb2new = Vb.*Vb;
Vb2old = p.con(:,3).*p.con(:,3);

p.con(:,8) = p.con(:,8).*p.con(:,3)./Vb;

if p.ty1
  k = Vb2new(p.ty1).*p.con(p.ty1,2)./Vb2old(p.ty1)/Settings.mva;
  p.con(p.ty1,9) = k.*p.con(p.ty1,9);
  p.con(p.ty1,10) = k.*p.con(p.ty1,10);
end

if p.ty2
  k = Settings.mva*Vb2old(p.ty2)./p.con(p.ty2,2)./Vb2new(p.ty2);
  p.con(p.ty2,15) = k.*p.con(p.ty2,15);
  p.con(p.ty2,16) = k.*p.con(p.ty2,16);
end
