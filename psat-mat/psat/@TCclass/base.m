function p = base(p)

global Line Bus Settings

if ~p.n, return, end

[p.B,p.y] = factsbase(Line,p.line,p.Cp,'TCSC');

fm_errv(p.con(:,6),'Tcsc',p.bus1)

Vb2old = p.con(:,6).*p.con(:,6);
Vb2new = getkv(Bus,p.bus1,2);

k = Settings.mva*Vb2old./p.con(:,5)./Vb2new;

if p.ty1
  p.con(p.ty1,10) = k(p.ty1).*p.con(p.ty1,10);
  p.con(p.ty1,11) = k(p.ty1).*p.con(p.ty1,11);
end
if p.ty2
  p.con(p.ty2,14) = k(p.ty2).*p.con(p.ty2,14);
  p.con(p.ty2,15) = k(p.ty2).*p.con(p.ty2,15);
end

