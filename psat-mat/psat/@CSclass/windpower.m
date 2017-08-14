function output = windpower(a,rho,vw,Ar,R,omega,u,type)

lambda = ~u+omega.*R./vw;
lambdai = 1./(1./lambda+0.002);

switch type
 
 case 1 
  
  % Pw 
  cp = 0.44*(125./lambdai-6.94).*exp(-16.5./lambdai);
  output = 0.5*rho.*cp.*Ar.*vw.^3;
 
 case 2
  
  output = zeros(length(omega),2);
  a1 = exp(-16.5./lambda-0.0330);
  a2 = 125./lambda-6.690;
  
  % d Pw / d omega
  output(:,1) = rho.*(-27.5+3.63*a2).*a1.*Ar.*vw.^4./omega./omega./R;

  % d Pw / d vw
  output(:,2) = rho.*((27.5-3.63*a2)./lambda+0.66*a2).*a1.*Ar.*vw.^2;

end
