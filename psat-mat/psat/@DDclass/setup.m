function a = setup(a)

global Bus

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
[a.bus,a.vbus] = getbus(Bus,a.con(:,1));
a.wind = round(a.con(:,2));
a.dat = zeros(a.n,4);

a.u = ones(a.n,1);
if length(a.con(1,:)) <= 25
  a.con(:,25) = 1;
else
  a.u = a.con(:,a.ncol);
end

% fix generator number
a.con(:,25) = round(a.con(:,25));
idx = find(a.con(:,25) <= 0);
if ~isempty(idx), a.con(idx,25) = 1; end

a.u = a.u.*fm_genstatus(a.bus);
a.store = a.con;
