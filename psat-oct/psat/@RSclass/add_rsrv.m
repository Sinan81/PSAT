function a = add_rsrv(a,data)

global Bus

newbus = getint_bus(Bus,data(:,1));

if length(data(1,:)) < a.ncol
  data(:,a.ncol) = 1;
end

a.n = a.n + length(data(:,1));
a.con = [a.con; data];
a.bus = [a.bus; newbus];
a.Pr = [a.Pr; zeros(length(data(:,1)),1)];
a.u = [a.u; data(:,a.ncol)];
