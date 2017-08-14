function y = ybus(a,buslist)

global Bus

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

y = sparse(a.bus(idx),a.bus(idx),a.con(idx,5)+sqrt(-1)*a.con(idx,6),nb,nb);
