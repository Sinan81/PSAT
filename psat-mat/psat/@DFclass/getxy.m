function [x,y] = getxy(a,bus,x,y)

global Wind

if ~a.n, return, end

h = find(ismember(a.bus,bus));

if ~isempty(h)
  vw = Wind.vw(a.wind(h));
  ws = Wind.ws(a.wind(h));
  x = [x; a.theta_p(h); a.omega_m(h); a.idr(h); a.iqr(h); vw];
  y = [y; a.pwa(h); a.vref(h); ws];
end
