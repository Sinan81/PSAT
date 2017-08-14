function [x,y] = getxy(a,bus,x,y)

global Wind

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  x = [x; a.id(h); a.iq(h)];
end
