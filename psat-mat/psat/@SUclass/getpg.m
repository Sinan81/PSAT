function p = getpg(a,idx)

p = 0;

if ~a.n, return, end

if ~isempty(idx)
  p = sum(a.u(idx).*a.con(idx,3));
end
