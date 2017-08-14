function p = fcall(p)

global DAE Line

if ~p.n, return, end

t2 = p.con(:,3) == 2;
ta = p.con(:,4) == 2;
i2 = find(t2);

x0 = DAE.y(p.x0);
x1 = DAE.x(p.x1);
Pref = DAE.y(p.pref);

[Ps,Qs,Pr,Qr] = flows(Line,'pq',p.line);
[Ps,Qs,Pr,Qr] = flows(p,Ps,Qs,Pr,Qr,'tcsc');

Ki = p.con(:,13);

fx2 = p.u.*t2.*Ki.*(Pref - Ps - ta.*Pr);
DAE.f(p.x2(i2)) = fx2(i2);
DAE.f(p.x1) = p.u.*(x0-x1)./p.con(:,9);

% anti-windup limit
fm_windup(p.x1,p.con(:,10),p.con(:,11),'f')

% update B
p.B = btcsc(p);
