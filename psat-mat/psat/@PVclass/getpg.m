function p = getpg(a,idx)

p = 0;
if ~a.n, return, end
if isempty(idx), return, end
if isnumeric(idx)
  p = a.u(idx).*a.con(idx,4);
elseif strcmp(idx,'all')
  p = a.u.*a.con(:,4);
end
