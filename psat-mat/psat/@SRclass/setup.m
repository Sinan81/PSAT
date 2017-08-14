function a = setup(a)

global Bus

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
[a.bus,a.vbus] = getbus(Bus,a.con(:,1));
a.Tm = zeros(a.n,1);
a.Efd = zeros(a.n,1);

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end
a.u = a.u.*fm_genstatus(a.bus);

a.store = a.con;
