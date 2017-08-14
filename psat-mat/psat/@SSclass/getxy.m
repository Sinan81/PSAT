function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

h1 = ismember(a.bus1,bus);
h2 = ismember(a.bus2,bus);
h = find(h1+h2);

if ~isempty(h)
  x_temp = [a.vcs(h); a.vpi(h)];
  idx = find(x_temp);
  x = [x; x_temp(idx)];
  y = [y; a.v0(h); a.pref(h)];
end
