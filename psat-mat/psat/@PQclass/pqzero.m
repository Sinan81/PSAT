function a = pqzero(a,idx)

if ~a.n, return, end

if isnumeric(idx)
  a.con(idx,4) = 0;
  a.con(idx,5) = 0;
elseif strcmp(idx,'all')
  a.con(:,4) = 0;
  a.con(:,5) = 0;
elseif strcmp(idx,'pos')
  idx = find(a.u.*a.con(:,4) >= 0);
  a.con(idx,4) = 0;
  a.con(idx,5) = 0;
end
