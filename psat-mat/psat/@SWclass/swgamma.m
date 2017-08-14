function y = swgamma(a,idx)

y = 0;
if ~a.n, return, end
if isnumeric(idx)
  y = a.u(idx).*a.con(idx,11);
elseif strcmp(idx,'sum')
  y = a.u.*sum(a.con(:,11));
end
