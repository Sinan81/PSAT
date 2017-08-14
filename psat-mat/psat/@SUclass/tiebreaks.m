function KTBS = tiebreaks(a)

global OPF

if ~OPF.tiebreak,
  KTBS = zeros(a.n,1);
else
  % a Tiebreaks
  if length(a.con(1,:)) < 14
    KTBS = zeros(a.n,1);
  else
    KTBS = a.u.*a.con(:,14);
  end
  idx = find(a.u.*a.con(:,4) == 0);
  if ~isempty(idx)
    KTBS(idx) = 0;
  end
  idx = find(a.u.*a.con(:,4));
  if ~isempty(idx)
    KTBS(idx) = KTBS(idx)./a.con(idx,4);
  end
end
