function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

global Dfig

h = ismember(Dfig.bus(a.gen),bus);

if ~isempty(h)
  x = [x; a.Dfm(h); a.x(h); a.csi(h); a.pfw(h)];
  y = [y; a.pf1(h); a.pwa(h)];
end
