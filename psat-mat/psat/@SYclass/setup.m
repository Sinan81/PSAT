function a = setup(a)

global Bus

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));

ncol = length(a.con(1,:));
switch ncol
 case 19
  a.con = [a.con,zeros(a.n,2),ones(a.n,2),zeros(a.n,4),ones(a.n,1)];
 case 20
  a.con = [a.con,zeros(a.n,1),ones(a.n,2),zeros(a.n,4),ones(a.n,1)];
 case 21
  a.con = [a.con,ones(a.n,2),zeros(a.n,4),ones(a.n,1)];
 case 22
  a.con = [a.con,ones(a.n,1),zeros(a.n,4),ones(a.n,1)];
 case 23
  a.con = [a.con,zeros(a.n,4),ones(a.n,1)];
 case 24
  a.con = [a.con,zeros(a.n,3),ones(a.n,1)];
 case 25
  a.con = [a.con,zeros(a.n,2),ones(a.n,1)];
 case 26
  a.con = [a.con,zeros(a.n,1),ones(a.n,1)];
 case 27
  a.con(:,28) = a.con(:,27);
  a.con(:,27) = ones(a.n,1);
end

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end

a.n = length(a.con(:,1));
[a.bus,a.vbus] = getbus(Bus,a.con(:,1));
a.u = a.u.*fm_genstatus(a.bus);

a.pm0 = zeros(a.n,1);
a.vf0 = zeros(a.n,1);
a.J11 = zeros(a.n,1);
a.J12 = zeros(a.n,1);
a.J21 = zeros(a.n,1);
a.J22 = zeros(a.n,1);

a.store = a.con;
