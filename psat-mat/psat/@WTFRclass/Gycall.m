function Gycall(p)

global DAE

if ~p.n, return, end

DAE.Gy = DAE.Gy - sparse(p.pf1, p.pf1, 1, DAE.m, DAE.m); 
DAE.Gy = DAE.Gy - sparse(p.pwa, p.pwa, 1, DAE.m, DAE.m); 
%DAE.Gy = DAE.Gy - sparse(p.pout, p.pout, 1, DAE.m, DAE.m);
