function a = base(a)

global Syn

if ~a.n, return, end

% reset generator parameters
a.M = getvar(Syn,a.gen,'M');
for i = 1:a.n
  idx = a.syn{i};
  a.Mtot(i,1) = sum(a.M(idx));
end


