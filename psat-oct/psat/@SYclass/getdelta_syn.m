function delta = getdelta_syn(a)

global DAE

delta = [];

if ~a.n, return, end

delta = a.u.*DAE.x(a.delta);
