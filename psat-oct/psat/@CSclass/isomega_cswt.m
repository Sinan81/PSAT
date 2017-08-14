function out = isomega_cswt(a,idx)

out = isdelta_cswt(a,idx+1) || isdelta_cswt(a,idx+2);