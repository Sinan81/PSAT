function fcall(p)

global DAE

if ~p.n, return, end

global DAE

DAE.f(p.v) = p.u.*(DAE.y(p.If) - p.con(:,6))./p.con(:,2);

% anti-windup limit
fm_windup(p.v,p.con(:,7),0,'f')
