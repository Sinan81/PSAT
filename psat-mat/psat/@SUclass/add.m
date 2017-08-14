function a = add(a,data)

global Bus

newbus = getint(Bus,data(:,1));

if length(data(1,:)) < a.ncol
  data(:,a.ncol) = 1;
end

a.n = a.n + length(data(:,1));
a.con = [a.con; data];
a.bus = [a.bus; newbus];
a.u = [a.u; data(:,a.ncol)];
