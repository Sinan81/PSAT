function idx = findpos(a)

global CPF

idx = [];
if ~a.n, return, end

if CPF.onlypqgen
  idx = find(a.u & a.gen);
  if isempty(idx)
    fm_disp('No PQ generator found. Expect meaningless results.')
  end
elseif CPF.onlynegload
  idx = find(a.u.*a.con(:,4) < 0);
  if isempty(idx)
    fm_disp('No negative load found. Expect meaningless results.')
  end
elseif CPF.negload
  idx = find(a.u);
else
  idx = find(a.u.*a.con(:,4) >= 0);
end

