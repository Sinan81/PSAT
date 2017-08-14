function gcall_tg(p)
% Jacobian matrix Gy
global DAE

if ~p.n, return, end

DAE.Gy = DAE.Gy - sparse(p.wref,p.wref,1,DAE.m,DAE.m);
