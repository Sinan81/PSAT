function a = swzero(a,idx)

if ~a.n, return, end
if isnumeric(idx)
  a.pg(idx) = 0;
elseif strcmp(idx,'all')
  a.pg = zeros(a.n,1);  
end
