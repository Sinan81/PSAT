function a = setup(a)

global Bus

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
a.type = a.con(:,3);

a.idx = a.con(:,1);
idx = find(a.type == 1); % voltage control
if ~isempty(idx)
  a.idx(idx) = getvint(Bus,a.con(idx,1));
end

if length(a.con(1,:)) == a.ncol+1
  a.con = a.con(:,[1:12,14])
end

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end

a.store = a.con;


