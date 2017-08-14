function [x,y] = getxy_pmu(a,bus,x,y)

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  x = [x; a.vm(h); a.thetam(h)];
end
