function [buses,idxes] = sortbus_bus(a,maxn)

[buses,idxes] = sort(a.names(1:min(a.n,maxn)));
