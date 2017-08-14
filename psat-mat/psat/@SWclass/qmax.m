function [q,idx] = qmax(a)

global Bus Settings

if a.n
  q = a.u.*a.con(:,6);
  idx = a.bus;
elseif ~isempty(a.store)
  q = a.store(:,a.ncol).*a.store(:,6).*a.store(:,2)/Settings.mva;
  idx = getint(Bus,a.store(:,1));
else
  q = [];
  idx = [];
end
