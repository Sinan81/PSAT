function fcall(p)

global DAE

if ~p.n, return, end

Vs = DAE.x(p.Vs);
Qgr = p.con(:,7);

DAE.f(p.Vs) = (Qgr.*DAE.y(p.cac)-DAE.y(p.q)).*p.dVsdQ.*p.u;

% anti-windup limits
fm_windup(p.Vs,p.con(:,8),p.con(:,9),'f')
