function gcall(a)

global DAE

if ~a.n, return, end

V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);
a1 = DAE.y(a.bus1);
a2 = DAE.y(a.bus2);
ss = sin(a1-a2);
cc = cos(a1-a2);

c1 = a.u.*DAE.x(a.vcs).*a.y./ssscden(a);  
P1 = c1.*V1.*V2.*ss;  
Q1 = c1.*(V1.^2-V1.*V2.*cc);
Q2 = c1.*(V2.^2-V1.*V2.*cc);

ty2 = find(a.con(:,2) == 2);
ty3 = find(a.con(:,2) == 3);

V0 = a.V0;

if ty2
  den = ssscden(a);
  kp = a.Cp(ty2)./(1-a.Cp(ty2));
  V0(ty2) = kp.*den(ty2);
end

if ty3   
  global Line
  [Ps,Qs,Pr,Qr] = flows(Line,'pq',a.line);
  [Ps,Qs,Pr,Qr] = flows(a,Ps,Qs,Pr,Qr,'sssc');
  Kpr = a.con(:,11);
  tp = ty3(find(a.con(ty3,10) == 1));
  ta = ty3(find(a.con(ty3,10) == 2));    
  if tp
    V0(tp) = Kpr(tp).*(DAE.y(a.pref(tp))-Ps(tp)) + DAE.x(a.vpi(tp));
  end
  if ta
    V0(ta) = Kpr(ta).*(DAE.y(a.pref(ta))-Ps(ta)-Pr(ta)) + DAE.x(a.vpi(ta));
  end
end

DAE.g = DAE.g ...
        + sparse(a.bus1,1,P1,DAE.m,1) ...
        - sparse(a.bus2,1,P1,DAE.m,1) ...
        + sparse(a.v1,1,Q1,DAE.m,1) ...
        + sparse(a.v2,1,Q2,DAE.m,1) ...
        + sparse(a.v0,1,V0-DAE.y(a.v0),DAE.m,1) ...
        + sparse(a.pref,1,a.Pref-DAE.y(a.pref),DAE.m,1); 
