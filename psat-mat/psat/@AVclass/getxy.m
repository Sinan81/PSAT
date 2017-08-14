function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  x_temp = [a.vm(h); a.vr1(h); a.vr2(h); a.vr3(h); a.vf(h)];
  idx = find(x_temp);
  x = [x; x_temp(idx)];
  y = [y; a.vref(h)];
end

