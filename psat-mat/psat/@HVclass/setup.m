function a = setup(a)

global Bus Settings

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));

[a.bus1,a.v1] = getbus(Bus,a.con(:,1));
[a.bus2,a.v2] = getbus(Bus,a.con(:,2));

% Data Structure: a.dat:
% col #1: 1/Rd
% col #2: Ld/Rd
% col #3: cosar_max
% col #4: cosar_min
% col #5: cosgi_max
% col #6: cosgi_min
% col #7: 1/KI
% col #8: Vn*In/Sn
% col #9:  dc current control
% col #10: dc power control
% col #11: dc voltage control

a.dat = zeros(a.n,11);

a.dat(:,1) = a.con(:,15);
a.dat(:,2) = a.con(:,16)./a.con(:,15);
a.dat(:,3) = cos(pi*a.con(:,18)/180);
a.dat(:,4) = cos(pi*a.con(:,17)/180);
a.dat(:,5) = cos(pi*a.con(:,20)/180);
a.dat(:,6) = cos(pi*a.con(:,19)/180);
a.dat(:,7) = 1./a.con(:,13);
a.dat(:,8) = a.con(:,7).*a.con(:,8)./a.con(:,3);
idx = find(a.con(:,25) == 1);
if ~isempty(idx), a.dat(idx,9) = 1; end
idx = find(a.con(:,25) == 2);
if ~isempty(idx), a.dat(idx,10) = 1; end
idx = find(a.con(:,25) == 3);
if ~isempty(idx), a.dat(idx,11) = 1; end

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end

a.store = a.con;

Settings.nseries = Settings.nseries + a.n;
