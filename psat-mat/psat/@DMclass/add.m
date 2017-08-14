function a = add(a,data)

if isempty(data), return, end

global Bus

if ischar(data)
  data = [1,100,0,0,1e-6,zeros(1,12),1];
end

if length(data(1,:)) < a.ncol
  data(:,a.ncol) = 1;
end

a.con = [a.con; data];
a.n = length(a.con(:,1));
[a.bus,a.vbus] = getbus(Bus,a.con(:,1));
if length(a.con(1,:)) < a.ncol
  a.con(:,a.ncol) = ones(a.n,1);
end 
a.u = a.con(:,a.ncol);
