function [u,v] = getbus(a,idx)

u = a.int(round(idx));
v = u + a.n;
