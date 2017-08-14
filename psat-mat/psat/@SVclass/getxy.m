function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  x_temp = [a.bcv(h); a.alpha(h); a.vm(h)];
  idx = find(x_temp);
  x = [x; x_temp(idx)];
  y = [y; a.vref(h); a.q(h)];
end
