function a = move2sup_pv(a,idx)

if ~a.n, return, end

global Supply

if isempty(idx), return, end

data = zeros(length(idx),15);
data(:,[1 2 3 15]) = a.con(idx,[1 2 4 10]);
Supply = add_supply(Supply,data);

a = remove_pv(a,idx);
