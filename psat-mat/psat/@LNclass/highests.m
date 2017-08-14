function values = highests(a)

global DAE Bus Settings Varname Varout

values = [];

if ~a.n, return, end

n1 = DAE.n+DAE.m+2*Bus.n+6*Settings.nseries;
idx = find(Varname.idx > n1 & Varname.idx <= n1+a.n);

if isempty(idx), return, end

out = Varout.vars(:,idx);

for k = 1:length(idx)
  h = Varname.idx(idx(k)) - n1;
  if a.con(h,15)
    out(:,k) = out(:,k)/a.con(h,15);
  end
end

vals = max(out,[],1);
[y,jdx] = sort(vals,2,'descend');

if length(jdx) > 3, jdx = jdx(1:3); end

values = idx(jdx);
