function delta = approxdelta_syn(a)

global DAE

delta = a.u.*(DAE.x(a.delta)-a.con(:,9).*DAE.y(a.pm));
