function fcall(a)

global DAE Settings Syn

if ~a.n, return, end

for i = 1:a.n
  idx = a.syn{i};
  DAE.f = DAE.f + sparse(a.dgen(idx),1,2*pi*Settings.freq*(1-DAE.y(a.omega(i)))*Syn.u(idx),DAE.n,1);
end
