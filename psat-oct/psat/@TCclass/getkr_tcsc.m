function kr = getkr_tcsc(a,idx)

kr = [];

if ~a.n, return, end
if isempty(idx), return, end

kr = a.u(idx).*a.con(idx,16);
