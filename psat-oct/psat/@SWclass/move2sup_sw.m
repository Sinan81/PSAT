function a = move2sup_sw(a)

if ~a.n, return, end

global Supply

idx = find(a.u);
data = zeros(a.n,15);
data(:,[1 2 15]) = a.con(:,[1 2 11]);
data(:,3) = a.pg;
Supply = add_supply(Supply,data(idx,:));
a.pg(idx) = 0;
