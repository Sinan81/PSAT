function a = setup(a)

global Bus

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
[a.bus,a.vbus] = getbus(Bus,a.con(:,1));

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end
a.u = a.u.*fm_genstatus(a.bus);

% RTon2F
a.con(:,20) = 0.5*8.314*a.con(:,20)/96487;

a.store = a.con;
