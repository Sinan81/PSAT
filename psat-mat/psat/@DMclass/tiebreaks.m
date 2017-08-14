function KTBD = tiebreaks(a)

global OPF

if ~OPF.tiebreak,
  KTBD = zeros(a.n,1);
else
  % Demand Tiebreaks
  if length(a.con(1,:)) < 15,
    KTBD = zeros(a.n,1);
  else,
    KTBD = a.u.*a.con(:,15);
  end
  idx = find(a.u.*a.con(:,5) == 0);
  if ~isempty(idx)
    KTBD(idx) = 0;
  end
  idx = find(a.u.*a.con(:,5));
  if ~isempty(idx)
    KTBD(idx) = KTBD(idx)./a.con(idx,5);
  end
end
