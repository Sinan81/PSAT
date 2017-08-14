function a = add(a,data)

global Bus

if isempty(data), return, end

n = length(data(:,1));
a.n = a.n + n;
[a.bus,a.vbus] = getbus(Bus,a.con(:,1));

m = length(data(1,:));
if  m < a.ncol
  a.u = [a.u; ones(n,1)];
  data = [data, zeros(n,a.ncol-m)];
else
  a.u = [a.u; data(:,a.ncol)];
end

a.con = [a.con; data];
