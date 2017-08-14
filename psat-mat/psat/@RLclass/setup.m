function a = setup(a)

global Demand

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
a.dem = round(a.con(:,1));
a.bus = Demand.bus(a.dem);
if length(a.con(1,:)) < a.ncol
  a.con(:,a.ncol) = ones(a.n,1);
end 
a.u = a.con(:,a.ncol);
a.store = a.con;
