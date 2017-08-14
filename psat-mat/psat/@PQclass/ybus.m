function y = ybus(a,buslist)

global Bus DAE

nb = Bus.n;
y = sparse(nb,nb);

if ~a.n, return, end

idx = [];
for i = 1:a.n,
  jdx = find(buslist ~= a.bus(i));
  if ~isempty(jdx) && a.u(i), 
    idx = [idx; i]; 
  end
end

if isempty(idx), return, end

pqg = a.con(idx,4)./DAE.y(a.vbus(idx))./DAE.y(a.vbus(idx));
pqb = a.con(idx,5)./DAE.y(a.vbus(idx))./DAE.y(a.vbus(idx));

y = sparse(a.bus(idx),a.bus(idx),pqg-sqrt(-1)*pqb,nb,nb);

