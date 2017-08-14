function p = fcall(p)

global DAE

if ~p.n, return, end

type = p.con(:,2);
ty1 = find(type == 1);
ty2 = find(type == 2);
ty3 = find(type == 3);

vg = DAE.y(p.vbus);
vrmax = p.u.*p.con(:,3);
vrmin = p.u.*p.con(:,4);
Te = p.con(:,10);
Tr = p.con(:,11);
A = p.con(:,12);
B = p.con(:,13);

DAE.f(p.vm)  = p.u.*(vg - DAE.x(p.vm))./Tr;

if ty1

  vm  = DAE.x(p.vm(ty1));
  vr1 = DAE.x(p.vr1(ty1));
  vr2 = DAE.x(p.vr2(ty1));
  vf = DAE.x(p.vf(ty1));
  vref = DAE.y(p.vref(ty1));
  m0 = p.con(ty1,5);
  T1 = p.con(ty1,6);
  T2 = p.con(ty1,7);
  T3 = p.con(ty1,8);
  T4 = p.con(ty1,9);
  K1 = m0.*T2./T1;
  K2 = m0 - K1;
  K3 = T4./T3;
  K4 = 1 - K3;

  vr = m0.*vr2 + K3.*(K1.*(vref - vm) + vr1);

  DAE.f(p.vr1(ty1)) = p.u(ty1).*(K2.*(vref - vm) - vr1)./T1;
  DAE.f(p.vr2(ty1)) = p.u(ty1).*(K4.*(vr1 + K1.*(vref - vm)) - m0.*vr2)./(T3.*m0);

  % hard limit
  vr = min(vr,vrmax(ty1));
  vr = max(vr,vrmin(ty1));
  DAE.f(p.vf(ty1)) = p.u(ty1).*(-vf+vr-ceiling(p,vf,A(ty1),B(ty1),1))./Te(ty1);

end

if ty2
  
  vm  = DAE.x(p.vm(ty2));
  vr1 = DAE.x(p.vr1(ty2));
  vr2 = DAE.x(p.vr2(ty2));
  vf = DAE.x(p.vf(ty2));
  vref = DAE.y(p.vref(ty2));
  Ke = p.con(ty2,9);
  Ka = p.con(ty2,5);
  Ta = p.con(ty2,6);
  Kf = p.con(ty2,7);
  Tf = p.con(ty2,8);
  K5 = Kf./Tf;

  DAE.f(p.vr1(ty2)) = p.u(ty2).*(Ka.*(vref-vm-vr2-K5.*vf)-vr1)./Ta;
  DAE.f(p.vr2(ty2)) = -p.u(ty2).*(K5.*vf+vr2)./Tf;

  % non-windup limiter
  idx = find(vr1 >= vrmax(ty2) & DAE.f(p.vr1(ty2)) > 0);
  if ~isempty(idx), DAE.f(p.vr1(ty2(idx))) = 0; end
  idx = find(vr1 <= vrmin(ty2) & DAE.f(p.vr1(ty2)) < 0);
  if ~isempty(idx), DAE.f(p.vr1(ty2(idx))) = 0; end
  vr1 = min(vr1,vrmax(ty2));
  vr1 = max(vr1,vrmin(ty2));
  DAE.x(p.vr1(ty2)) = p.u(ty2).*vr1;

  DAE.f(p.vf(ty2)) = p.u(ty2).*(vr1-Ke.*vf-ceiling(p,vf,A(ty2),B(ty2),1))./Te(ty2);

end

if ty3
  
  vm  = DAE.x(p.vm(ty3));
  vr3 = DAE.x(p.vr3(ty3));
  vf = DAE.x(p.vf(ty3));
  vref = DAE.y(p.vref(ty3));
  Kr  = p.con(ty3,5);
  T2r = p.con(ty3,6);
  T1r = p.con(ty3,7);
  Kr1 = Kr.*T1r./T2r;
  Kr2 = Kr - Kr1;
  vf0 = p.con(ty3,8);
  v0  = p.con(ty3,9);
  z = p.con(ty3,9) ~= 0;
  s = z.*vg(ty3)./(v0 + ~z) + ~z;

  DAE.f(p.vr3(ty3)) = p.u(ty3).*(Kr2.*(vref - vm) - vr3)./T2r;
  DAE.f(p.vf(ty3)) = p.u(ty3).*((vr3+Kr1.*(vref-vm)+vf0).*s-vf)./Te(ty3);

  % anti-windup limiter
  fm_windup(p.vf(ty3),vrmax(ty3),vrmin(ty3),'f')

end
