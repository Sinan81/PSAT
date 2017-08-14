function gcall(a)

global DAE Line

if ~a.n, return, end

V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);
t1 = DAE.y(a.bus1);
t2 = DAE.y(a.bus2);
ss = sin(t1-t2);
cc = cos(t1-t2);

% update B
B = btcsc(a);

P1 = V1.*V2.*ss.*B;

DAE.g = DAE.g ...
        + sparse(a.bus1,1,P1,DAE.m,1) ...
        - sparse(a.bus2,1,P1,DAE.m,1) ...
        + sparse(a.v1,1,V1.*(V1-V2.*cc).*B,DAE.m,1) ...
        + sparse(a.v2,1,V2.*(V2-V1.*cc).*B,DAE.m,1); 

tx = a.con(:,3) == 1;
t2 = a.con(:,3) == 2;
ta = a.con(:,4) == 2;   

x0 = a.X0;
x2 = zeros(a.n,1);
x2(find(t2)) = DAE.x(a.x2(find(t2)));
Pref = DAE.y(a.pref);

[Ps,Qs,Pr,Qr] = flows(Line,'pq',a.line);
[Ps,Qs,Pr,Qr] = flows(a,Ps,Qs,Pr,Qr,'tcsc');

Kp = a.con(:,12);

% x0 = -t2.*Kp.*(Pref-Ps-ta.*Pr) + x2;
% x0 = t2.*Kp.*(Pref-Ps-ta.*Pr) + x2;
x0 = tx.*x0 + t2.*(Kp.*(Pref-Ps-ta.*Pr) + x2);

DAE.g = DAE.g ...
        + sparse(a.x0,1,x0-DAE.y(a.x0),DAE.m,1) ...
        + sparse(a.pref,1,a.Pref-DAE.y(a.pref),DAE.m,1);

