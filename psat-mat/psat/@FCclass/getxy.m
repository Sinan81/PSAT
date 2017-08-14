function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  x = [x; a.Ik(h); a.Vk(h); a.pH2(h); a.pH2O(h); a.pO2(h); a.qH2(h); a.m(h)];
end

