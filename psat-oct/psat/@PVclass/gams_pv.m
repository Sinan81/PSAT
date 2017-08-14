function [n,idx,data] = gams_pv(a)

global Bus

n = int2str(a.n);
idx = sparse(a.bus,[1:a.n],1,Bus.n,a.n);
data = getzeros_bus(Bus);
if a.n
  data(a.bus) = a.u.*a.con(:,10);
end
