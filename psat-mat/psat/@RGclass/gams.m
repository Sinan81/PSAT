function data = gams(a,data,sdx)

if ~a.n, return, end

idx = find(a.u);

if ~isempty(idx)
  data(a.sup(idx),sdx) = a.con(idx,[9,5,6,3,4,7,8]);
end
