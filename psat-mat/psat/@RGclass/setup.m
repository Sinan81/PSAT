function a = setup(a)

global Supply

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
a.sup = round(a.con(:,1));
a.bus = Supply.bus(a.sup);
if length(a.con(1,:)) < a.ncol
  a.con(:,a.ncol) = ones(a.n,1);
end 
a.u = a.con(:,a.ncol);
a.store = a.con;
