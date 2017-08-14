function a = pqreset(a,idx)

if ~a.n, return, end
if isnumeric(idx)
  a.con(idx,4) = a.P0(idx);
  a.con(idx,5) = a.Q0(idx);
elseif strcmp(idx,'all')
  a.con(:,4) = a.P0;
  a.con(:,5) = a.Q0;
end
