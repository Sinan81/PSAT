function [qmax,qmin] = swlim(a)

global Bus

if ~a.n
  qmax = [];
  qmin = [];
  return
end

qmax = find(Bus.Qg(a.bus) > a.con(:,6) & a.u);
qmin = find(Bus.Qg(a.bus) < a.con(:,7) & a.u);

