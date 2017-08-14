function p = getvg(a,idx)

p = 0;
if ~a.n, return, end
if isempty(idx), return, end
if isnumeric(idx)
  p = a.con(idx(find(a.u(idx))),4);
elseif strcmp(idx,'all')
  p = a.con(find(a.u),4);
end
