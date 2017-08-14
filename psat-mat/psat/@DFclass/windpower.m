function output = windpower(a,rho,vw,Ar,R,omega,theta,type)

lambda = omega.*R./vw;
lambdai = 1./(1./(lambda+0.08*theta)-0.035./(theta.^3+1));

switch type
 
 case 1 % Pw

  cp = 0.22*(116./lambdai-0.4*theta-5).*exp(-12.5./lambdai);
  output = 0.5*rho.*cp.*Ar.*vw.^3;

 case 2 % d Pw / d x

  output = zeros(length(omega),3);

  a1 = exp(-12.5./lambdai);
  a2 = (lambda+0.08*theta).^2;
  a3 = 116./lambdai-0.4*theta-5;
  a4 = -9.28./(lambda+0.08*theta).^2 + ...
       12.180*theta.*theta./(theta.^3+1).^2-0.4;
  a5 = 1.000./(lambda+0.08*theta).^2 - ...
       1.3125*theta.*theta./(theta.^3+1).^2;

  % d Pw / d omega_m
  output(:,1) = R.*a1.*rho.*vw.*vw.*Ar.*(-12.760+1.3750*a3)./a2;

  % d Pw / d vw
  output(:,2) = (omega.*R.*(12.760-1.3750*a3)./a2 ...
      + 0.330*a3.*vw).*vw.*Ar.*rho.*a1;

  % d Pw / d theta_p
  output(:,3) = 0.110*rho.*(a4 + a3.*a5).*a1.*Ar.*vw.^3;

end
