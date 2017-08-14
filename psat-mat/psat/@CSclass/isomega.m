function out = isomega(a,idx)

out = isdelta(a,idx+1) || isdelta(a,idx+2);