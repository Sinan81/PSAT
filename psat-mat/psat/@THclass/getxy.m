function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  x = [x; a.T(h); a.x(h)];
  y = [y, a.G(h)];
end
