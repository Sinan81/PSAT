function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

h1 = ismember(a.bus1,bus);
h2 = ismember(a.bus2,bus);
h = find(h1+h2);

if ~isempty(h)
  x = [x; a.vp(h); a.vq(h); a.iq(h)];
  y = [y; a.vp0(h); a.vq0(h); a.vref(h)];
end
