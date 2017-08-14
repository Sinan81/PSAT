function a = pvzero(a,idx)

if ~a.n, return, end
if isnumeric(idx)
  a.con(idx,4) = 0;
elseif strcmp(idx,'all')
  a.con(:,4) = 0;  
end
