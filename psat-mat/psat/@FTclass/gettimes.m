function t = gettimes(a)

t = [];

if ~a.n, return, end 

u = unique([a.con(:,5); a.con(:,6)]);
t = [u-1e-6; u];
