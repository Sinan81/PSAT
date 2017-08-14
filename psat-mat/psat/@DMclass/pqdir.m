function [p,q] = pqdir(a,idx)

p = 0;
q = 0;

if ~a.n, return, end

if ~isempty(idx)
  p = sum(a.u(idx).*a.con(idx,3));
  q = sum(a.u(idx).*a.con(idx,4));
end
