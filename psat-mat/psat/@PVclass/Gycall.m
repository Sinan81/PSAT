function Gycall(p)

global Settings

if ~p.n, return, end

if Settings.pv2pq
  fm_setgy(p.vbus(find(~p.pq & p.u)));
else
  fm_setgy(p.vbus(find(p.u)));
end
