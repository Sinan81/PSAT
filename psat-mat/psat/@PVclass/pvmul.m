function a = pvmul(a,idx,k)

if ~a.n, return, end

if isnumeric(idx)
  a.con(idx,4) = k*a.con(idx,4);
elseif strcmp(idx,'all')
  a.con(:,4) = k*a.con(:,4);  
end
