function YBB = diagy(a)

YBB = [];

if ~a.n, return, end

r = a.con(:,8);
x = a.con(:,9);
z = r + i*x;
y = a.u./z;
YBB = diag(y);
