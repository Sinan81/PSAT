function y = pvgamma(a,idx)

y = 0;
if ~a.n, return, end
if isnumeric(idx)
  y = a.u(idx).*a.con(idx,10);
elseif strcmp(idx,'sum')
  y = sum(a.u.*a.con(:,10));
end
