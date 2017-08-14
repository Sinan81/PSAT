function p = pqshunt(p)

global DAE Settings

if ~p.n, return, end

if ~Settings.pq2z || Settings.init > 1, return, end

if Settings.forcepq
  fm_disp(' * The option "Settings.forcepq" overwrites the option "Settings.pq2z".')
  fm_disp(' * All PQ loads will be forced to consume constant powers.')
  return
end

p.shunt = ~p.gen;
idx = find(p.shunt);
if isempty(idx), return, end
p.con(idx,7) = DAE.y(p.vbus(idx));
p.con(idx,8) = 0;
