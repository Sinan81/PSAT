function [x,y] = getxy(a,bus,x,y)

global Wind

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  y = [y; a.vref(h)];
  x = [x; a.btx1(h); a.id(h); a.iq(h)];
end
