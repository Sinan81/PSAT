function [p,q] = pqdir(a,idx)  

p = 0;
q = 0;

if ~a.n, return, end

if ~isempty(idx)
  p = a.P0(idx);
  q = a.Q0(idx);
end
