function Fxcall(p)
%Jacobian matrix Gx,Fx,Fy
global DAE Syn Settings

if ~p.n, return, end
%%
if p.ty1
  pm1 = p.pm(p.ty1);
  tg1 = p.dat1(:,1);
  tg2 = p.dat1(:,2);
  tg3 = p.dat1(:,3);
  u1 = p.u(p.ty1);
  tin = p.dat1(:,15);
  u = tin < p.con(p.ty1,5) & tin > p.con(p.ty1,6); % windup limiter
  DAE.Fx = DAE.Fx - sparse(tg1,p.dat1(:,14),u.*u1.*p.dat1(:,7).*p.dat1(:,4),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg1,tg1,p.dat1(:,7),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg2,tg2,p.dat1(:,8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg3,tg3,p.dat1(:,9),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg2,tg1,u1.*p.dat1(:,8).*p.dat1(:,11),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg3,tg2,u1.*p.dat1(:,9).*p.dat1(:,13),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg3,tg1,u1.*p.dat1(:,10).*p.dat1(:,13).*p.dat1(:,9),DAE.n,DAE.n);
  DAE.Fy = DAE.Fy + sparse(tg1,p.wref(p.ty1),u.*u1.*p.dat1(:,7).*p.dat1(:,4),DAE.n,DAE.m);
  DAE.Gx = DAE.Gx + sparse(pm1,tg3,u1,DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(pm1,tg2,u1.*p.dat1(:,12),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(pm1,tg1,u1.*p.dat1(:,10).*p.dat1(:,12),DAE.m,DAE.n);
end
%%
if p.ty2
  tg = p.dat2(:,1);
  pm2 = p.pm(p.ty2);
  tin = DAE.y(p.pm(p.ty2));
  u = tin < p.dat2(:,3) & tin > p.dat2(:,4) & p.u(p.ty2); % windup limiter
  DAE.Fx = DAE.Fx - sparse(tg,tg,p.dat2(:,6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg,p.dat2(:,9),p.u(p.ty2).*p.dat2(:,6).*p.dat2(:,8),DAE.n,DAE.n);
  DAE.Fy = DAE.Fy + sparse(tg,p.wref(p.ty2),p.u(p.ty2).*p.dat2(:,6).*p.dat2(:,8),DAE.n,DAE.m);
  DAE.Gx = DAE.Gx + sparse(pm2,tg,u,DAE.m,DAE.n);
  DAE.Gx = DAE.Gx - sparse(pm2,p.dat2(:,9),u.*p.dat2(:,7),DAE.m,DAE.n);
end
%%
if p.ty3
  pm3 = p.pm(p.ty3);
  tg1 = p.dat3(:,1);
  tg2 = p.dat3(:,2);
  tg3 = p.dat3(:,3);
  tg4 = p.dat3(:,4);
  u3 = p.u(p.ty3);
  delta_G = p.dat3(:,18);
  v = p.dat3(:,19);
  u_G = delta_G < (p.con(p.ty3,5)-p.dat3(:,6)) & delta_G > (p.con(p.ty3,6)-p.dat3(:,6)); % windup limiter
  u_v = v < p.con(p.ty3,7) & v > p.con(p.ty3,8); % windup limiter
  DAE.Fx = DAE.Fx - sparse(tg1,p.dat3(:,17),u3.*p.dat3(:,5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg1,tg1,p.dat3(:,7),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg1,tg2,u_G.*u3.*(p.dat3(:,14)+p.dat3(:,15)).*p.dat3(:,5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg1,tg3,u3.*p.dat3(:,5).*p.dat3(:,15).*p.dat3(:,8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg2,tg1,u_v.*u3,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg3,tg2,u_G.*u3,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg3,tg3,p.dat3(:,8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg4,tg2,u_G.*u3.*p.dat3(:,12).*p.dat3(:,11),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg4,tg4,p.dat3(:,11),DAE.n,DAE.n);

  DAE.Fy = DAE.Fy + sparse(tg1,p.wref(p.ty3),u3.*p.dat3(:,5),DAE.n,DAE.m);

  DAE.Gx = DAE.Gx + sparse(pm3,tg2,u_G.*u3.*p.dat3(:,10).*p.dat3(:,13),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(pm3,tg4,u3,DAE.m,DAE.n);
end
%%
if p.ty4
  pm4 = p.pm(p.ty4);
  tg1 = p.dat4(:,1);
  tg2 = p.dat4(:,2);
  tg3 = p.dat4(:,3);
  tg4 = p.dat4(:,4);
  tg5 = p.dat4(:,5);
  u4 = p.u(p.ty4);
  G = p.dat4(:,21);
  v = p.dat4(:,22);
  u = G < p.con(p.ty4,5) & G > p.con(p.ty4,6); % windup limiter
  u0 = v < p.con(p.ty4,7) & v > p.con(p.ty4,8); % windup limiter
  DAE.Fx = DAE.Fx - sparse(tg1,p.dat4(:,20),u4.*p.dat4(:,18),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg2,p.dat4(:,20),u4.*p.dat4(:,6).*p.dat4(:,17),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg2,tg1,u4.*p.dat4(:,6),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg2,tg2,p.dat4(:,8),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg2,tg3,u.*u4.*p.dat4(:,6).*(p.dat4(:,15)+p.dat4(:,16)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg2,tg4,u4.*p.dat4(:,6).*p.dat4(:,16).*p.dat4(:,9),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg3,tg2,u0.*u4,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg4,tg3,u.*u4,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg4,tg4,p.dat4(:,9),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg5,tg3,u.*u4.*p.dat4(:,13).*p.dat4(:,12),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg5,tg5,p.dat4(:,12),DAE.n,DAE.n);
  
  DAE.Fy = DAE.Fy + sparse(tg1,p.wref(p.ty4),u4.*p.dat4(:,18),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(tg2,p.wref(p.ty4),u4.*p.dat4(:,6).*p.dat4(:,17),DAE.n,DAE.m);
  
  DAE.Gx = DAE.Gx + sparse(pm4,tg5,u4,DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(pm4,tg3,u.*u4.*p.dat4(:,14).*p.dat4(:,11),DAE.m,DAE.n);
end
%%
if p.ty5
  pm5 = p.pm(p.ty5);
  tg1 = p.dat5(:,1);
  tg2 = p.dat5(:,2);
  tg3 = p.dat5(:,3);
  tg4 = p.dat5(:,4);
  u5 = p.u(p.ty5);
  z = p.dat5(:,13);
  v = p.dat5(:,14);
  u_z = z < p.con(p.ty5,5) & z > p.con(p.ty5,6); % windup limiter
  u_v = v < p.con(p.ty5,7) & v > p.con(p.ty5,8); % windup limiter
  DAE.Fx = DAE.Fx - sparse(tg1,p.dat5(:,12),u5.*p.dat5(:,7),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg1,tg1,p.dat5(:,7).*(p.dat5(:,11).*p.dat5(:,9)-1),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg1,tg2,u5.*p.dat5(:,7).*p.dat5(:,11),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg2,tg1,u5.*p.dat5(:,10),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg3,tg1,u5.*u_v.*p.dat5(:,5).*p.dat5(:,9),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg3,tg2,u5.*u_v.*p.dat5(:,5),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg3,tg3,u_z.*u_v.*p.dat5(:,5),DAE.n,DAE.n);
%   DAE.Fx = DAE.Fx + sparse(tg4,tg3,u_z.*u5.*2.*p.dat5(:,8).*((p.dat5(:,4)).^2)./((p.dat5(:,6)).^3),DAE.n,DAE.n);
%   DAE.Fx = DAE.Fx - sparse(tg4,tg4,2.*p.dat5(:,8).*p.dat5(:,6)./(z.^2),DAE.n,DAE.n);
% partly linearize at steady state  
%   DAE.Fx = DAE.Fx + sparse(tg4,tg3,u_z.*u5.*2.*p.dat5(:,8)./p.dat5(:,6),DAE.n,DAE.n);
%   DAE.Fx = DAE.Fx - sparse(tg4,tg4,2.*p.dat5(:,8).*p.dat5(:,6)./(z.^2),DAE.n,DAE.n);
% linearize at steady state
  DAE.Fx = DAE.Fx + sparse(tg4,tg3,u_z.*u5.*2.*p.dat5(:,8).*((p.dat5(:,4)).^2)./((p.dat5(:,3)).^3),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg4,tg4,2.*p.dat5(:,8).*p.dat5(:,4)./(z.^2),DAE.n,DAE.n);
  DAE.Fy = DAE.Fy + sparse(tg1,p.wref(p.ty5),u5.*p.dat5(:,7),DAE.n,DAE.m);
%   DAE.Gx = DAE.Gx - sparse(pm5,tg3,2.*u5.*u_z.*((p.dat5(:,4)).^3)./((p.dat5(:,6)).^3),DAE.m,DAE.n);
%   DAE.Gx = DAE.Gx + sparse(pm5,tg4,3.*u5.*(p.dat5(:,6).^2)./(z.^2),DAE.m,DAE.n);
% partly linearize at steady state
%   DAE.Gx = DAE.Gx - sparse(pm5,tg3,2.*u5.*u_z,DAE.m,DAE.n);
%   DAE.Gx = DAE.Gx + sparse(pm5,tg4,3.*u5.*(p.dat5(:,6).^2)./(z.^2),DAE.m,DAE.n);
% linearize at steady state
  DAE.Gx = DAE.Gx - sparse(pm5,tg3,2.*u5.*u_z.*((p.dat5(:,4)).^3)./((p.dat5(:,3)).^3),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(pm5,tg4,3.*u5.*(p.dat5(:,4).^2)./(z.^2),DAE.m,DAE.n);
% un-linearize   
end
%%
if p.ty6
  pm6 = p.pm(p.ty6);
  tg1 = p.dat6(:,1);
  tg2 = p.dat6(:,2);
  tg3 = p.dat6(:,3);
  tg4 = p.dat6(:,4);
  tg5 = p.dat6(:,5);
  u6 = p.u(p.ty6);
  g = p.dat6(:,19);
  v = p.dat6(:,20);
  G = g./p.dat6(:,13);
%   G = g.*p.dat6(:,13);
  u_g = G < p.con(p.ty6,5) & G > p.con(p.ty6,6); % windup limiter
  u_v = v < p.con(p.ty6,7) & v > p.con(p.ty6,8); % windup limiter 
  DAE.Fx = DAE.Fx - sparse(tg1,p.dat6(:,18),u6.*p.dat6(:,15),DAE.n,DAE.n); 
  DAE.Fx = DAE.Fx + sparse(tg2,p.dat6(:,18),u6.*p.dat6(:,12),DAE.n,DAE.n);  
  DAE.Fx = DAE.Fx - sparse(tg2,tg2,p.dat6(:,8),DAE.n,DAE.n);    
  DAE.Fx = DAE.Fx - sparse(tg3,p.dat6(:,18),u6.*p.dat6(:,6).*(p.dat6(:,14)+p.dat6(:,11)),DAE.n,DAE.n);  
  DAE.Fx = DAE.Fx + sparse(tg3,tg1,u6.*p.dat6(:,6),DAE.n,DAE.n); 
  DAE.Fx = DAE.Fx + sparse(tg3,tg2,u6.*p.dat6(:,6),DAE.n,DAE.n);  
  DAE.Fx = DAE.Fx - sparse(tg3,tg3,p.dat6(:,9),DAE.n,DAE.n); 
  DAE.Fx = DAE.Fx - sparse(tg3,tg4,u6.*u_g.*p.dat6(:,6),DAE.n,DAE.n);  
  DAE.Fx = DAE.Fx + sparse(tg4,tg3,u_v.*u6,DAE.n,DAE.n);
  DAE.Fx = DAE.Fx + sparse(tg5,tg4,u_g.*u6.*p.dat6(:,10).*(tg5.^2).*(p.dat6(:,13).^2).*...
       2./(tg4.^3),DAE.n,DAE.n);
%   DAE.Fx = DAE.Fx + sparse(tg5,tg4,u_g.*u6.*2.*p.dat6(:,10).*(tg5.^2)./((p.dat6(:,13).^2).*...
%        (tg4.^3)),DAE.n,DAE.n);
  DAE.Fx = DAE.Fx - sparse(tg5,tg5,p.dat6(:,10).*2.*tg5./(G.^2),DAE.n,DAE.n);
  
  DAE.Fy = DAE.Fy + sparse(tg1,p.wref(p.ty6),u6.*p.dat6(:,15),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy - sparse(tg2,p.wref(p.ty6),u6.*p.dat6(:,12),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(tg3,p.wref(p.ty6),u6.*p.dat6(:,6).*(p.dat6(:,14)+p.dat6(:,11)),DAE.n,DAE.m);
   DAE.Gx = DAE.Gx + sparse(pm6,tg4,u6.*u_g.*(-2).*(tg5.^3).*(p.dat6(:,13).^2)./(tg4.^3),DAE.m,DAE.n); 
%   DAE.Gx = DAE.Gx + sparse(pm6,tg4,u6.*u_g.*(-2).*(tg5.^3)./((p.dat6(:,13).^2).*(tg4.^3)),DAE.m,DAE.n);
  DAE.Gx = DAE.Gx + sparse(pm6,tg5,u6.*3.*(tg5.^2)./(G.^2),DAE.m,DAE.n);
end
