function Fxcall(a)

global DAE

if ~a.n, return, end

V = DAE.y(a.vbus);

if ~isempty(a.ty1)
  bcv = DAE.x(a.bcv);
  Tr = a.con(a.ty1,6);
  Kr = a.con(a.ty1,7);
  bcv_max = a.con(a.ty1,9);
  bcv_min = a.con(a.ty1,10);
  DAE.Fx = DAE.Fx - sparse(a.bcv,a.bcv,a.u(a.ty1)./Tr,DAE.n,DAE.n);
  u = bcv < bcv_max & bcv > bcv_min & a.u(a.ty1);
  DAE.Gx = DAE.Gx + sparse(a.q(a.ty1),a.bcv,u.*V(a.ty1).^2,DAE.m,DAE.n);
  DAE.Fy = DAE.Fy - sparse(a.bcv,a.vbus(a.ty1),u.*Kr./Tr,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(a.bcv,a.vref(a.ty1),u.*Kr./Tr,DAE.n,DAE.m);
end

if ~isempty(a.ty2)
  alpha = DAE.x(a.alpha);
  vm = DAE.x(a.vm);
  a_max = a.con(a.ty2,9);
  a_min = a.con(a.ty2,10);
  T2 = a.con(a.ty2,6);
  K = a.con(a.ty2,7);
  Kd = a.con(a.ty2,11);
  T1 = a.con(a.ty2,12);
  Km = a.u(a.ty2).*a.con(a.ty2,13);
  Tm = a.con(a.ty2,14);
  xl = a.con(a.ty2,15);
  xc = a.con(a.ty2,16);
  DAE.Fx = DAE.Fx - sparse(a.vm,a.vm,a.u(a.ty2)./Tm,DAE.n,DAE.n);
  DAE.Fy = DAE.Fy + sparse(a.vm,a.vbus(a.ty2),Km./Tm,DAE.n,DAE.m);
  DAE.Fx = DAE.Fx - sparse(a.alpha,a.alpha,a.u(a.ty2).*Kd./T2,DAE.n,DAE.n);
  u = alpha < a_max & alpha > a_min & a.u(a.ty2);
  k1 = -u.*K.*T1./T2./Tm.*Km;
  k2 = u.*K.*T1./T2./Tm - K./T2;
  k3 = -2*u.*V(a.ty2).*V(a.ty2).*(1-cos(2*alpha))./xl/pi;
  DAE.Fy = DAE.Fy + sparse(a.alpha,a.vbus(a.ty2),k1,DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(a.alpha,a.vref(a.ty2),u.*K./T2,DAE.n,DAE.m);
  DAE.Fx = DAE.Fx + sparse(a.alpha,a.vm,k2,DAE.n,DAE.n);
  DAE.Gx = DAE.Gx - sparse(a.q(a.ty2),a.alpha,k3,DAE.m,DAE.n);
end
