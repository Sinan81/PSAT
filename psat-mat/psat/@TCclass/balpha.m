function out = balpha(p,af,idx,type)

xC = p.con(p.ty2(idx),15);
xL = p.con(p.ty2(idx),14);

switch type
 case 1
  kx1 = sqrt(xC./xL);
  kx2 = kx1.*kx1;
  kx3 = kx2.*kx1;
  kx4 = kx3.*kx1;
  ckf = cos(kx1.*(pi-af));
  skf = sin(kx1.*(pi-af));
  s2a = sin(2*af);
  caf = cos(af);
  saf = sin(af);
  out = (pi*(kx4-2*kx2+1).*ckf)./(xC.*((pi*kx4-pi-2*kx4.*af+2*af.*kx2- ...
      kx4.*s2a+kx2.*s2a-4*kx2.*caf.*saf).*ckf -4*kx3.*caf.*caf.*skf));
 case 2
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
  out = 2*pi*(-kx4+2*kx2-1).*(2*skf.*skf.*kx1.*kx3.*ca2-ck2.*kx4+ck2.*kx2- ...
      ck2.*kx4.*c2a+ck2.*kx2.*c2a+2*ck2.*kx2.*saf.*saf-2*ck2.*kx2.*ca2- ...
      4*ckf.*kx3.*caf.*skf.*saf+2*kx3.*ca2.*ck2.*kx1)./xC./(ckf.*pi.*kx4- ...
      ckf.*pi-2*ckf.*kx4.*af+2*ckf.*af.*kx2-ckf.*kx4.*s2a+ckf.*kx2.*s2a- ...
      4*ckf.*kx2.*caf.*saf+4*kx3.*ca2.*skf).^2;
end
