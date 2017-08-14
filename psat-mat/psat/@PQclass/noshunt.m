function a = noshunt(a)

if ~a.n, return, end

idx = find(a.shunt);
if isempty(idx), return, end

global Bus

a.con(idx,7) = a.store(idx,7).*a.con(idx,3)./getkv(Bus,a.bus(idx),1);
a.con(idx,8) = a.store(idx,8);
a.shunt = zeros(a.n,1);
