function fcall(p)

global DAE Settings

if ~p.n, return, end

m = DAE.x(p.m);
h = p.u.*p.con(:,4);
k = p.u.*p.con(:,5);

DAE.f(p.m) = -h.*m + k.*(DAE.y(p.vbus)./m - p.con(:,8));

% non-windup limits
fm_windup(p.m,p.con(:,6),p.con(:,7),'pf')
