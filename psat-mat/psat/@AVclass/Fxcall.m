function Fxcall(p)

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

% common AVR Jacobians
DAE.Gx = DAE.Gx + sparse(p.vfd,p.vf,p.u,DAE.m,DAE.n);
DAE.Fx = DAE.Fx - sparse(p.vm,p.vm,1./Tr,DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(p.vm,p.vbus,p.u./Tr,DAE.n,DAE.m);

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
  K1 = p.u(ty1).*m0.*T2./T1;
  K2 = p.u(ty1).*m0 - K1;
  K3 = p.u(ty1).*T4./T3;
  K4 = p.u(ty1) - K3;
  vr = m0.*vr2 + K3.*(K1.*(vref - vm) + vr1);
  z = vr < vrmax(ty1) & vr > vrmin(ty1);

  DAE.Fx = DAE.Fx - sparse(p.vr1(ty1),p.vm(ty1),K2./T1,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vr1(ty1),p.vr1(ty1),1./T1,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vr2(ty1),p.vm(ty1),K4.*K1./T3./m0,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(p.vr2(ty1),p.vr1(ty1),K4./T3./m0,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vr2(ty1),p.vr2(ty1),1./T3,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vf(ty1),p.vf(ty1),(1+ceiling(p,vf,A(ty1),B(ty1),2))./Te(ty1),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(p.vf(ty1),p.vr1(ty1),z.*K3./Te(ty1),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vf(ty1),p.vm(ty1),z.*K3.*K1./Te(ty1),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(p.vf(ty1),p.vr2(ty1),z.*p.u(ty1).*m0./Te(ty1),DAE.n,DAE.n);
  DAE.Fy = DAE.Fy + sparse(p.vr1(ty1),p.vref(ty1),K2./T1,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.vr2(ty1),p.vref(ty1),K4.*K1./T3./m0,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.vf(ty1),p.vref(ty1),z.*K3.*K1./Te(ty1),DAE.n,DAE.m);

end

if ty2
  
  vr1 = DAE.x(p.vr1(ty2));
  vf = DAE.x(p.vf(ty2));
  Ke = p.con(ty2,9);
  Ka = p.u(ty2).*p.con(ty2,5);
  Ta = p.con(ty2,6);
  Kf = p.u(ty2).*p.con(ty2,7);
  Tf = p.con(ty2,8);
  K5 = Kf./Tf;
  z = vr1 < vrmax(ty2) & vr1 > vrmin(ty2) & p.u(ty2);
  
  DAE.Fx = DAE.Fx - sparse(p.vr2(ty2),p.vr2(ty2),1./Tf,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vr2(ty2),p.vf(ty2),K5./Tf,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vf(ty2),p.vf(ty2),(Ke+ceiling(p,vf,A(ty2),B(ty2),2))./Te(ty2),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(p.vf(ty2),p.vr1(ty2),z./Te(ty2),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vr1(ty2),p.vm(ty2),z.*Ka./Ta,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vr1(ty2),p.vr1(ty2),1./Ta,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vr1(ty2),p.vr2(ty2),z.*Ka./Ta,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vr1(ty2),p.vf(ty2),z.*K5.*Ka./Ta,DAE.n,DAE.n);
  DAE.Fy = DAE.Fy + sparse(p.vr1(ty2),p.vref(ty2),z.*Ka./Ta,DAE.n,DAE.m);
  
end

if ty3
  
  vm  = DAE.x(p.vm(ty3));
  vr3 = DAE.x(p.vr3(ty3));
  vf = DAE.x(p.vf(ty3));
  Kr  = p.u(ty3).*p.con(ty3,5);
  T2r = p.con(ty3,6);
  T1r = p.con(ty3,7);
  Kr1 = Kr.*T1r./T2r;
  Kr2 = Kr - Kr1;
  vf0 = p.con(ty3,8);
  v0  = p.con(ty3,9);
  vref = DAE.y(p.vref(ty3));
  w = p.con(ty3,9) ~= 0;
  s = w.*vg(ty3)./(v0 + ~w) + ~w;
  z = vf < vrmax(ty3) & vf > vrmin(ty3) & p.u(ty3);

  DAE.Fx = DAE.Fx - sparse(p.vr3(ty3),p.vr3(ty3),1./T2r,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vr3(ty3),p.vm(ty3),Kr2./T2r,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vf(ty3),p.vf(ty3),1./Te(ty3),DAE.n,DAE.n);
  DAE.Fy = DAE.Fy + sparse(p.vr3(ty3),p.vref(ty3),Kr2./T2r,DAE.n,DAE.m);

  DAE.Fx = DAE.Fx + sparse(p.vf(ty3),p.vr3(ty3),z.*s./Te(ty3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(p.vf(ty3),p.vm(ty3),z.*Kr1.*s./Te(ty3),DAE.n,DAE.n);
  DAE.Fy = DAE.Fy + sparse(p.vf(ty3),p.vref(ty3),z.*Kr1.*s./Te(ty3),DAE.n,DAE.m);  
  DAE.Fy = DAE.Fy + sparse(p.vf(ty3),p.vbus(ty3),w.*z.*(vr3+Kr1.*(vref-vm)+vf0)./(v0+(~w))./Te(ty3),DAE.n,DAE.m);

end
