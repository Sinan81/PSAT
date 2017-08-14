function data = dmdata(a,idx)

global Bus

data = zeros(1,17);
data(1) = getidx(Bus,1);

if ~a.n, return, end

data = zeros(length(idx),17);
data(:,[1 2]) = a.con(idx,[1 2]);
data(:,3) = a.u(idx).*a.con(idx,4);
data(:,4) = a.u(idx).*a.con(idx,5);
data(:,14) = 1;
