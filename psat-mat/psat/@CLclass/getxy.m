function [x,y] = getxy(a,bus,x,y)

global Exc Svc

if ~a.n, return, end

buses = zeros(a.n,1);
buses(a.exc) = Exc.bus(a.con(a.exc,2));
buses(a.svc) = Svc.bus(a.con(a.svc,2));

h = find(ismember(buses,bus));

if ~isempty(h)
  x = [x; a.Vs(h)];
end
