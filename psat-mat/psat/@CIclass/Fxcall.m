function Fxcall(a)

global DAE Settings Syn

if ~a.n, return, end

for i = 1:a.n
  idx = a.syn{i};
  n = length(idx);
  odx = a.omega(i)*ones(n,1);
  DAE.Fy = DAE.Fy - sparse(a.dgen(idx),odx,2*pi*Settings.freq*Syn.u(idx),DAE.n,DAE.m);
  DAE.Gx = DAE.Gx + sparse(a.delta(i),a.dgen(idx),a.M(idx)/a.Mtot(i),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(a.omega(i),a.wgen(idx),a.M(idx)/a.Mtot(i),DAE.m,DAE.n);
end
