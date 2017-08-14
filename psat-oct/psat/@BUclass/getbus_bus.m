function [u,v] = getbus_bus(a,idx)

u = a.int(round(idx));
v = u + a.n;
