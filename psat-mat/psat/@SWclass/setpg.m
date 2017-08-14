function a = setpg(a,idx,p)

if ~a.n, return, end
if isempty(idx), return, end
if isnumeric(idx)
  jdx = idx(find(a.u(idx)));
elseif strcmp(idx,'all')
  jdx = find(a.u);
end

a.pg(jdx) = a.u(jdx).*p(jdx);
%a.store(jdx,10) = a.pg(jdx);
