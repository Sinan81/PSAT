function val = tanphi(a,idx)

val = [];
if ~a.n, return, end

if isnumeric(idx)
  p = a.con(idx,4);
  jdx = find(p == 0);
  if ~isempty(jdx), p(jdx) = 0; end
  val = a.u(idx).*a.con(idx,5)./p;
  if ~isempty(jdx), val(jdx) = 1; end
elseif strcmp(idx,'all')
  p = a.con(:,4);
  jdx = find(p == 0);
  if ~isempty(jdx), p(jdx) = 1; end
  val = a.u.*a.con(:,5)./p;  
  if ~isempty(jdx), val(jdx) = 0; end
end
