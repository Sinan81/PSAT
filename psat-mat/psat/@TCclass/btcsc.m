function B = btcsc(p)

global DAE

B = p.B;

if p.ty1
  y = p.y(p.ty1);
  x = DAE.x(p.x1(p.ty1));
  B(p.ty1) = p.u(p.ty1).*y.*(y.*x)./(1-y.*x);
end

if p.ty2
  xC = p.con(p.ty2,15);
  xL = p.con(p.ty2,14);
  af = DAE.x(p.x1(p.ty2));
  kx1 = sqrt(xC./xL);
  kx2 = kx1.*kx1;
  kx3 = kx2.*kx1;
  kx4 = kx3.*kx1;
  ckf = cos(kx1.*(pi-af));
  skf = sin(kx1.*(pi-af));
  s2a = sin(2*af);
  caf = cos(af);
  saf = sin(af);
  B(p.ty2) = p.u(p.ty2).*(pi*(kx4-2*kx2+1).*ckf)./(xC.*((pi*kx4-pi- ...
             2*kx4.*af+2*af.*kx2-kx4.*s2a+kx2.*s2a-4*kx2.*caf.*saf).*ckf ...
             -4*kx3.*caf.*caf.*skf));
end
