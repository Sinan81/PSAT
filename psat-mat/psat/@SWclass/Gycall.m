function Gycall(p)

global Settings

if ~p.n, return, end

fm_setgy(p.bus(find(p.u)));

if Settings.pv2pq
  fm_setgy(p.vbus(find(~p.dq & p.u)));
else
  fm_setgy(p.vbus(find(p.u)));
end
