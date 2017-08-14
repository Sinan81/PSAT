function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  x_temp = [a.v1(h); a.v2(h); a.v3(h); a.va(h)];
  idx = find(x_temp);
  x = [x; x_temp(idx)];
  y = [y; a.vss(h)];
end
