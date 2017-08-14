function [x,y] = getxy(a,bus,x,y)
% returns indexes to the state and algebraic variables
if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  x_temp = [a.tg1(h);a.tg2(h);a.tg3(h);a.tg4(h);a.tg5(h);a.tg(h)];
  idx = find(x_temp);
  x = [x; x_temp(idx)];
  y = [y; a.wref(h)];
end
