function values = getidx(a,idx)

if ~a.n, return, end

if isempty(idx)
  values = [];
elseif idx(1) == 0
  values = a.con(:,1);
else
  values = a.con(idx,1);
end
