function data = growth(a,rr,idx)

data = [];

if ~a.n, return, end

data = [a.con(:,[1 2]),a.con(:,4).*rr(idx(a.bus)),a.con(:,5).*rr(idx(a.bus)),zeros(a.n,13),ones(a.n,1)];
