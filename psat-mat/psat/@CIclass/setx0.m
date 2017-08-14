function a = setx0(a)

global DAE Syn

if ~a.n, return, end

for i = 1:a.n
  idx = a.syn{i};
  DAE.y(a.delta(i)) = sum(a.M(idx).*DAE.x(a.dgen(idx)))/a.Mtot(i);
end
DAE.y(a.omega) = 1;

fm_disp('Initialization of COI completed.')


