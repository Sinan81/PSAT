function idx = pqdisplay_pq(a)

global PV SW

idx = 0;

for i = 1:a.n
  bpv = findbus_pv(PV,a.bus(i));
  bsw = findbus_sw(SW,a.bus(i));
  bpq = a.u(i)*a.con(i,4) > 0;
  if isempty(bpv) && isempty(bsw) && bpq
    idx = a.bus(i);
    break
  end
end
