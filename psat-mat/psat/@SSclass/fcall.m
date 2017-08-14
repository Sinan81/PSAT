function fcall(p)

global DAE

if ~p.n, return, end

vcs = DAE.x(p.vcs);
ty3 = find(p.con(:,2) == 3);

if ty3   
  global Line
  [Ps,Qs,Pr,Qr] = flows(Line,'pq',p.line);
  [Ps,Qs,Pr,Qr] = flows(p,Ps,Qs,Pr,Qr,'sssc');
  Kin = p.con(:,12);
  tp = ty3(find(p.con(ty3,10) == 1));
  ta = ty3(find(p.con(ty3,10) == 2));    
  if tp
    DAE.f(p.vpi(tp)) = p.u(tp).*Kin(tp).*(DAE.y(p.pref(tp))-Ps(tp));
  end
  if ta
    DAE.f(p.vpi(ta)) = p.u(ta).*Kin(ta).*(DAE.y(p.pref(ta))-Ps(ta)-Pr(ta));
  end
end

DAE.f(p.vcs) = p.u.*(DAE.y(p.v0)-vcs)./p.con(:,7);

% anti-windup limit
fm_windup(p.vcs,p.con(:,8),p.con(:,9),'f')
