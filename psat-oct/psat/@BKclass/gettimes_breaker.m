function t = gettimes_breaker(a)

t = [];

if ~a.n, return, end 

u = unique([a.t1; a.t2]);
t = [u-1e-6; u];

