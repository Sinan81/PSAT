function p = fcall(p)
% computes differential equations f
global DAE 

if ~p.n, return, end

%%
if p.ty1
  tg1 = DAE.x(p.dat1(:,1));
  tg2 = DAE.x(p.dat1(:,2));
  tg3 = DAE.x(p.dat1(:,3));
  wref = DAE.y(p.wref(p.ty1));
  tin = p.dat1(:,6) + p.dat1(:,4).*(wref-DAE.x(p.dat1(:,14)));
  tin = max(tin,p.con(p.ty1,6));
  tin = min(tin,p.con(p.ty1,5));
  p.dat1(:,15) = tin;
  DAE.f(p.dat1(:,1)) = p.u(p.ty1).*p.dat1(:,7).*(-tg1 + tin);
  DAE.f(p.dat1(:,2)) = p.u(p.ty1).*p.dat1(:,8).*(-tg2 + p.dat1(:,11).*tg1);
  DAE.f(p.dat1(:,3)) = p.u(p.ty1).*p.dat1(:,9).*(-tg3 + p.dat1(:,13).*(tg2 + p.dat1(:,10).*tg1));
end
%%
if p.ty2
  wref = DAE.y(p.wref(p.ty2));
  tg = DAE.x(p.dat2(:,1));
  DAE.f(p.dat2(:,1)) = -p.u(p.ty2).*p.dat2(:,6).*(tg + p.dat2(:,8).*(DAE.x(p.dat2(:,9)) - wref));
end
%%
if p.ty3
  tg1 = DAE.x(p.dat3(:,1));
  tg2 = DAE.x(p.dat3(:,2));
  tg3 = DAE.x(p.dat3(:,3));
  tg4 = DAE.x(p.dat3(:,4));
  wref = DAE.y(p.wref(p.ty3));
  % gate position limits
  delta_G = tg2;                      
  delta_G = max(delta_G,(p.con(p.ty3,6)-p.dat3(:,6)));
  delta_G = min(delta_G,(p.con(p.ty3,5)-p.dat3(:,6))); 
  p.dat3(:,18) = delta_G;
  % rate limits
  v = tg1;
  v = max(v,p.con(p.ty3,8));
  v = min(v,p.con(p.ty3,7)); 
  p.dat3(:,19) = v;
  % differential equations
  DAE.f(p.dat3(:,1)) = p.u(p.ty3).*(p.dat3(:,5).*(wref-DAE.x(p.dat3(:,17))-(p.dat3(:,15)...
      +p.dat3(:,14)).*delta_G +p.dat3(:,15).*p.dat3(:,8).*tg3)-p.dat3(:,7).*tg1);
  DAE.f(p.dat3(:,2)) = p.u(p.ty3).*v;
  DAE.f(p.dat3(:,3)) = p.u(p.ty3).*(delta_G-p.dat3(:,8).*tg3);
  DAE.f(p.dat3(:,4)) = p.u(p.ty3).*(p.dat3(:,11).*p.dat3(:,12).*(p.dat3(:,6)+delta_G)-...
      tg4.* p.dat3(:,11));
end
%%
if p.ty4
  tg1 = DAE.x(p.dat4(:,1));
  tg2 = DAE.x(p.dat4(:,2));
  tg3 = DAE.x(p.dat4(:,3));
  tg4 = DAE.x(p.dat4(:,4));
  tg5 = DAE.x(p.dat4(:,5));  
  wref = DAE.y(p.wref(p.ty4));
  % gate position limits
  G = tg3;                      
  G = max(G,p.con(p.ty4,6));
  G = min(G,p.con(p.ty4,5)); 
  p.dat4(:,21) = G;
  % rate limits
  v = tg2;
  v = max(v,p.con(p.ty4,8));
  v = min(v,p.con(p.ty4,7)); 
  p.dat4(:,22) = v;
  % differential equations
  DAE.f(p.dat4(:,1)) = p.u(p.ty4).*p.dat4(:,18).*(wref-DAE.x(p.dat4(:,20)));
  DAE.f(p.dat4(:,2)) = p.u(p.ty4).*(p.dat4(:,6).*(tg1+p.dat4(:,17).*(wref-DAE.x(p.dat4(:,20)))...
      +p.dat4(:,16).*p.dat4(:,9).*tg4-(p.dat4(:,15)+p.dat4(:,16)).*G)-p.dat4(:,8).*tg2);
  DAE.f(p.dat4(:,3)) = p.u(p.ty4).*v;
  DAE.f(p.dat4(:,4)) = p.u(p.ty4).*(G-p.dat4(:,9).*tg4);
  DAE.f(p.dat4(:,5)) = p.u(p.ty4).*(p.dat4(:,13).*p.dat4(:,12).*G -tg5.* p.dat4(:,12));
end
%%
if p.ty5
  tg1 = DAE.x(p.dat5(:,1));
  tg2 = DAE.x(p.dat5(:,2));
  tg3 = DAE.x(p.dat5(:,3));
  tg4 = DAE.x(p.dat5(:,4));
  wref = DAE.y(p.wref(p.ty5));
  m=tg2+tg1.*p.dat5(:,9);
  % gate position limits
  z = tg3;                      
  z = max(z,p.con(p.ty5,6));
  z = min(z,p.con(p.ty5,5)); 
  p.dat5(:,13) = z;
  % rate limits
  v = p.dat5(:,5).*(m-z);
  v = max(v,p.con(p.ty5,8));
  v = min(v,p.con(p.ty5,7)); 
  p.dat5(:,14) = v;
  % differential equations
  DAE.f(p.dat5(:,1)) = p.u(p.ty5).*p.dat5(:,7).*(wref-DAE.x(p.dat5(:,12))-p.dat5(:,11)...
      .*(m -p.dat5(:,6))-tg1);
  DAE.f(p.dat5(:,2)) = p.u(p.ty5).*p.dat5(:,10).*tg1;
  DAE.f(p.dat5(:,3)) = p.u(p.ty5).*v;
  DAE.f(p.dat5(:,4)) = p.u(p.ty5).*p.dat5(:,8).*(1-(tg4./z).^2);
end
%%
if p.ty6
  tg1 = DAE.x(p.dat6(:,1));
  tg2 = DAE.x(p.dat6(:,2));
  tg3 = DAE.x(p.dat6(:,3));
  tg4 = DAE.x(p.dat6(:,4));
  tg5 = DAE.x(p.dat6(:,5));  
  wref = DAE.y(p.wref(p.ty6));
  % gate position limits
  g = tg4;                      
  g = max(g,p.con(p.ty6,6).*p.dat6(:,13));
  g = min(g,p.con(p.ty6,5).*p.dat6(:,13)); 
%   g = max(g,p.con(p.ty6,6)./p.dat6(:,13));
%   g = min(g,p.con(p.ty6,5)./p.dat6(:,13));
  p.dat6(:,19) = g;
  G = g./p.dat6(:,13);
%   G = g.*p.dat6(:,13);
  % rate limits
  v = tg3;
  v = max(v,p.con(p.ty6,8));
  v = min(v,p.con(p.ty6,7)); 
  p.dat6(:,20) = v;
  % differential equations
%   DAE.f(p.dat6(:,1)) = p.u(p.ty6).*p.dat6(:,15).*(wref-p.dat6(:,18)-p.dat6(:,17)...
%       .*(tg5((tg5./G).^2-p.dat6(:,16).*p.dat6(:,21))-p.dat6(:,7)));
%   
%   DAE.f(p.dat6(:,2)) = p.u(p.ty6).*p.dat6(:,12).*(wref-p.dat6(:,18)-p.dat6(:,17)...
%       .*(tg5((tg5./G).^2-p.dat6(:,16).*p.dat6(:,21))-p.dat6(:,7)))-p.dat6(:,8).*tg2;
%   
%   DAE.f(p.dat6(:,3)) = p.u(p.ty6).*p.dat6(:,6).*(tg1-tg2+(p.dat6(:,14)+p.dat6(:,11)).*(wref-p.dat6(:,18)-p.dat6(:,17)...
%       .*(tg5((tg5./G).^2-p.dat6(:,16).*p.dat6(:,21))-p.dat6(:,7))))-p.dat6(:,9).*tg3;
%   
%   DAE.f(p.dat6(:,4)) = p.u(p.ty6).*v;
%   DAE.f(p.dat6(:,5)) = p.u(p.ty6).*p.dat6(:,10).*(1-(tg5./G).^2+p.dat6(:,16).*p.dat6(:,21));

  DAE.f(p.dat6(:,1)) = p.u(p.ty6).*p.dat6(:,15).*(wref-p.dat6(:,18)-p.dat6(:,17)...
      .*(p.dat6(:,22)-p.dat6(:,7)));
  
  DAE.f(p.dat6(:,2)) = -p.u(p.ty6).*p.dat6(:,12).*(wref-p.dat6(:,18)-p.dat6(:,17)...
      .*(p.dat6(:,22)-p.dat6(:,7)))-p.dat6(:,8).*tg2;
  
  DAE.f(p.dat6(:,3)) = p.u(p.ty6).*p.dat6(:,6).*(tg1+tg2-g+(p.dat6(:,14)+p.dat6(:,11)).*...
      (wref-p.dat6(:,18)-p.dat6(:,17).*(p.dat6(:,22)-p.dat6(:,7))))-p.dat6(:,9).*tg3;
  
  DAE.f(p.dat6(:,4)) = p.u(p.ty6).*v;
  DAE.f(p.dat6(:,5)) = p.u(p.ty6).*p.dat6(:,10).*(1-(tg5./G).^2+p.dat6(:,16).*p.dat6(:,21));
end