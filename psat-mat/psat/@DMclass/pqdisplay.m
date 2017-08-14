function idx = pqdisplay(a)

global PV SW

idx = 0;

for i = 1:a.n
  bpv = findbus(PV,a.u(i)*a.bus(i));
  bsw = findbus(SW,a.u(i)*a.bus(i));
  bdm = a.u(i)*a.con(i,3) > 0;
  if isempty(bpv) && isempty(bsw) && bdm
    idx = a.bus(i);
    break
  end
end
