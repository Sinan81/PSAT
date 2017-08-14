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

a = setdat(a);

% start-up
a.z = ~a.con(:,6);
idx = find(a.con(:,18) < 0);
if ~isempty(idx), a.con(idx,18) = 0; end

a.store = a.con;


