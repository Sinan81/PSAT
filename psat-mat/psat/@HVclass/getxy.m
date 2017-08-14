function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

h1 = ismember(a.bus1,bus);
h2 = ismember(a.bus2,bus);
h = find(h1+h2);

if ~isempty(h)
  x = [x; a.Idc(h); a.xr(h); a.xc(h)];
  y = [y; a.cosa(h); a.cosg(h); a.phir(h); a.phii(h); ...
       a.Vrdc(h); a.Vidc(h); a.yr(h); a.yi(h)]; 
end
