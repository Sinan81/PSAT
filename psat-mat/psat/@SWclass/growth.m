function data = growth(a,rr,idx)

data = [];

if ~a.n, return, end

data = [a.con(:,[1 2]),a.con(:,10).*rr(idx(a.bus)),zeros(a.n,16),ones(a.n,1)];
