function p = getpg(a,idx)

p = 0;
if ~a.n, return, end
if isempty(idx), return, end
if isnumeric(idx)
  p = a.pg(idx(find(a.u(idx))));
elseif strcmp(idx,'all')
  p = a.pg(find(a.u));
end
