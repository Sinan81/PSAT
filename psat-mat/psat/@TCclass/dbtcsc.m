function DB = dbtcsc(p)

global DAE

DB = zeros(p.n,1);

if p.ty1
  y = p.y(p.ty1);
  x = DAE.x(p.x1(p.ty1));
  DB(p.ty1) = -p.u(p.ty1).*(y./(1-y.*x)).^2;  
end

if p.ty2
  xC = p.con(p.ty2,15);
  xL = p.con(p.ty2,14);
  af = DAE.x(p.x1(p.ty2));
  kx1 = sqrt(xC./xL);
  kx2 = kx1.*kx1;
  kx3 = kx2.*kx1;
  kx4 = kx3.*kx1;
  ckf = cos(kx1.*(-pi+af));
  skf = sin(kx1.*(-pi+af));
  ck2 = ckf.*ckf;
  c2a = cos(2*af);
  s2a = sin(2*af);
  caf = cos(af);
  saf = sin(af);
  ca2 = caf.*caf;
  DB(p.ty2) = 2*pi*p.u(p.ty2).*(-kx4+2*kx2-1).*(2*skf.*skf.*kx1.*kx3.*ca2-ck2.*kx4+ck2.*kx2- ...
              ck2.*kx4.*c2a+ck2.*kx2.*c2a+2*ck2.*kx2.*saf.*saf-2*ck2.*kx2.*ca2- ...
              4*ckf.*kx3.*caf.*skf.*saf+2*kx3.*ca2.*ck2.*kx1)./xC./(ckf.*pi.*kx4- ...
              ckf.*pi-2*ckf.*kx4.*af+2*ckf.*af.*kx2-ckf.*kx4.*s2a+ckf.*kx2.*s2a- ...
              4*ckf.*kx2.*caf.*saf+4*kx3.*ca2.*skf).^2;
end
