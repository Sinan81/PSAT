function pm = pmech(p)

global DAE Syn Settings

pm = zeros(p.n,1);
%%
if p.ty1
  pm(p.ty1) =  DAE.x(p.dat1(:,3)) + p.dat1(:,12).* ...
      (DAE.x(p.dat1(:,2)) + p.dat1(:,10).*DAE.x(p.dat1(:,1)));
end
%%
if p.ty2
  pm(p.ty2) = DAE.x(p.dat2(:,1)) - p.dat2(:,7).* ...
      (DAE.x(p.dat2(:,9)) - p.con(p.ty2,3)) + p.dat2(:,5);
  pm(p.ty2) = max(pm(p.ty2),p.dat2(:,4));
  pm(p.ty2) = min(pm(p.ty2),p.dat2(:,3));
end
%%
if p.ty3
  delta_G = p.dat3(:,18);
  pm(p.ty3) = DAE.x(p.dat3(:,4))+p.dat3(:,10).*p.dat3(:,13).*(delta_G+p.dat3(:,6)); 
 end
%%
if p.ty4
  G = p.dat4(:,21);
  pm(p.ty4) = DAE.x(p.dat4(:,5))+p.dat4(:,14).*p.dat4(:,11).*G; 
end
%%
if p.ty5
  z = p.dat5(:,13);
  pm(p.ty5) = (DAE.x(p.dat5(:,4))).^3./(z.^2); 
end
%%
if p.ty6
  G = p.dat6(:,19)./p.dat6(:,13);
%   G = p.dat6(:,19).*p.dat6(:,13);
  pm(p.ty6) = DAE.x(p.dat6(:,5)).*((DAE.x(p.dat6(:,5))./G).^2-p.dat6(:,16).*p.dat6(:,21)); 
end
