function [buses,idxes] = sortbus(a,maxn)

[buses,idxes] = sort(a.names(1:min(a.n,maxn)));
