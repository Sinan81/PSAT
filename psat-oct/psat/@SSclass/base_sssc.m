function p = base_sssc(p)

global Line Bus

if ~p.n, return, end

fm_errv(p.con(:,4),'Sssc',p.bus1)
Vb = getkv_bus(Bus,p.bus1,1);
p.con(:,9)  = p.con(:,9).*p.con(:,4)./Vb;
p.con(:,10) = p.con(:,10).*p.con(:,4)./Vb;

[p.xcs,p.y] = factsbase_line(Line,p.line,p.Cp,'SSSC');
