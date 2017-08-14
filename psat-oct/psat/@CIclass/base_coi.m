function a = base_coi(a)

global Syn

if ~a.n, return, end

% reset generator parameters
a.M = getvar_syn(Syn,a.gen,'M');
for i = 1:a.n
  idx = a.syn{i};
  a.Mtot(i,1) = sum(a.M(idx));
end


