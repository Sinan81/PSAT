function a = pqmul(a,idx,k)

if ~a.n, return, end

if isnumeric(idx)
  a.con(idx,4) = k*a.con(idx,4);
  a.con(idx,5) = k*a.con(idx,5);
elseif strcmp(idx,'all')
  a.con(:,4) = k*a.con(:,4);
  a.con(:,5) = k*a.con(:,5);
end
