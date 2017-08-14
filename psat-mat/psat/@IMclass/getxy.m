function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  x_temp = [a.slip(h); a.e1r(h); a.e1m(h); a.e2r(h); a.e2m(h)];
  idx = find(x_temp);
  x = [x; x_temp(idx)];
end
