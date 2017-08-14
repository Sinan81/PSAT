function [x,y] = getxy(a,bus,x,y)

global Exc Svc Cac

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  x = [x; a.q1(h)];
  y = [y; a.q(h)];
end
