function a = setx0(a)

global Bus DAE Settings Wind

if ~a.n, return, end

check = 1;

Pc = Bus.Pg(a.bus);
Qc = Bus.Qg(a.bus);
Vc = DAE.y(a.vbus);
ac = DAE.y(a.bus);

vds = -Vc.*sin(ac);
vqs =  Vc.*cos(ac);

rho = getrho(Wind,a.wind);

% Constants
% xs + xm
a.dat(:,1) = a.con(:,7) + a.con(:,10);
% xr + xm
a.dat(:,2) = a.con(:,9) + a.con(:,10);
% 1/(2*Hm)
a.dat(:,3) = 1./(2*a.con(:,11));
% etaGB*4*R*pi*f/p
a.dat(:,4) = 4*pi*Settings.freq*a.con(:,16)./a.con(:,17).*a.con(:,19);
% A
a.dat(:,5) = pi*a.con(:,16).*a.con(:,16);
% Vref
a.dat(:,6) = Vc;
% iqr max & min
a.dat(:,8) = -a.con(:,21)./a.con(:,10).*a.dat(:,1);
a.dat(:,9) = -a.con(:,20)./a.con(:,10).*a.dat(:,1);
% idr max & min
a.dat(:,10) = -((1./a.con(:,10)+a.con(:,23))./a.con(:,10)).*a.dat(:,1);
a.dat(:,11) = -((1./a.con(:,10)+a.con(:,22))./a.con(:,10)).*a.dat(:,1);

% Initialization of state variables

for i = 1:a.n
  
  % parameters
  Vds = vds(i);
  Vqs = vqs(i);
  Rs = a.con(i,6);
  Rr = a.con(i,8);
  Xm = a.con(i,10);
  x1 = a.dat(i,1);
  x2 = a.dat(i,2);
  Pg = Pc(i);
  Qg = Qc(i);

  % Initial guess
  Pb = Settings.mva*Pg/a.con(i,3);
  Pb = max(min(Pb,1),0);
  omega = (Pb+1)/2;
  slip = 1-omega;

  iqr = -x1*a.con(i,3)*(2*omega-1)/Vc(i)/Xm/Settings.mva/omega;
  A = [-Rs  x1; Vqs  -Vds];
  B = [Vds-Xm*iqr; Qg];
  Is = A\B;
  ids = Is(1);
  iqs = Is(2);
  idr = -(Vqs+Rs*iqs+x1*ids)/Xm;
  vdr = -Rr*idr+slip*(x2*iqr+Xm*iqs);
  vqr = -Rr*iqr-slip*(x2*idr+Xm*ids);
  
  jac = zeros(7,7);
  eqn = zeros(7,1);
  inc = ones(7,1);
  
  x = zeros(7,1);
  x(1) = ids;
  x(2) = iqs;
  x(3) = idr;
  x(4) = iqr;
  x(5) = vdr;
  x(6) = vqr;
  x(7) = 0.51;
  
  jac(1,1) = -Rs;
  jac(1,2) =  x1;
  jac(1,4) =  Xm;
  jac(2,1) = -x1;
  jac(2,2) = -Rs;
  jac(2,3) = -Xm;
  jac(3,3) = -Rr;
  jac(3,5) = -1;
  jac(4,4) = -Rr;
  jac(4,6) = -1;
  jac(5,1) =  Vds;
  jac(5,2) =  Vqs;
  %jac(6,1) =  Vqs;
  %jac(6,2) = -Vds;
  jac(6,3) = -Xm*Vc(i)/x1;
  
  k = x1*a.con(i,3)/Vc(i)/Xm/Settings.mva;
  
  iter = 0;
  
  while max(abs(inc)) > 1e-8
    
    if iter > 20
      fm_disp([' * * Initialization of doubly fed ind. gen. #', ...
               num2str(i),' failed.'])
      check = 0;
      break
    end
    
    eqn(1) = -Rs*x(1)+x1*x(2)+Xm*x(4)-Vds;
    eqn(2) = -Rs*x(2)-x1*x(1)-Xm*x(3)-Vqs;
    eqn(3) = -Rr*x(3)+(1-x(7))*(x2*x(4)+Xm*x(2))-x(5);
    eqn(4) = -Rr*x(4)-(1-x(7))*(x2*x(3)+Xm*x(1))-x(6);
    eqn(5) =  Vds*x(1)+Vqs*x(2)+x(5)*x(3)+x(6)*x(4)-Pg;
    eqn(6) = -Xm*Vc(i)*x(3)/x1-Vc(i)*Vc(i)/x1 - Qg;
    %eqn(6) =  Vqs*x(1)-Vds*x(2)-Qg;
    eqn(7) = -k*(2*x(7)-1)-x(4)*x(7);
    
    jac(3,2) = (1-x(7))*Xm;
    jac(3,4) = (1-x(7))*x2;
    jac(3,7) = -(x2*x(4)+Xm*x(2));
    jac(4,1) = -(1-x(7))*Xm;
    jac(4,3) = -(1-x(7))*x2;
    jac(4,7) = x2*x(3)+Xm*x(1);
    jac(5,3) = x(5);
    jac(5,4) = x(6);
    jac(5,5) = x(3);
    jac(5,6) = x(4);
    jac(7,4) = -x(7);
    jac(7,7) = -x(4)-2*k;
    
    inc = -jac\eqn;
    x = x + inc;
    iter = iter + 1;
    
  end
  
  ids = x(1);
  iqs = x(2);
  idr = x(3);
  iqr = x(4);
  vdr = x(5);
  vqr = x(6);
  omega = x(7);

  % theta_p
  theta = a.con(i,12)*round(1000*(omega-1))/1000;
  theta = max(theta,0);
  
  % wind turbine state variables
  DAE.x(a.idr(i)) = idr;
  DAE.x(a.iqr(i)) = iqr;
  DAE.x(a.omega_m(i)) = omega;
  DAE.x(a.theta_p(i)) = theta;
  % Vref
  Kv = a.con(i,14);
  if Kv == 0 % no voltage control
    a.dat(i,6) = 0;
  else
    a.dat(i,6) = Vc(i)-(idr+Vc(i)/Xm)/Kv;
  end
  % iqr offset (~= 0 if Pg = 1 p.u.)
  a.dat(i,7) = max(2*k*(omega-1)/omega,0);
  
  % electrical torque
  Tel = Xm*(iqr*ids-idr*iqs);
  if Pg < 0
    fm_disp([' * * Turbine power is negative at bus <',Bus.names{a.bus(i)},'>.'])
    fm_disp(['     Wind speed <',num2str(a.wind(i)),'> cannot be initilized.'])
    DAE.x(getidx(Wind,a.wind(i))) = 1;
    continue
  end
  % wind power [MW]
  Pw = Tel*omega*Settings.mva*1e6;
  % wind speed
  iter = 0;
  incvw = 1;
  eqnvw = 1;
  R = a.dat(i,4);
  AA = a.dat(i,5);
  % initial guess for wind speed
  vw = 0.9*getvw(Wind,a.wind(i));
  while abs(eqnvw) > 1e-7
    if iter > 50
      wspeed = num2str(a.wind(i));
      fm_disp([' * * Initialization of wind speed <', ...
               wspeed, '> failed (convergence problem).'])
      fm_disp(['     Tip: Try increasing the nominal wind speed <',wspeed,'>.'])
      check = 0;
      break
    end
    eqnvw = windpower(a,rho(i),vw,AA,R,omega,theta,1)-Pw;
    jacvw = windpower(a,rho(i),vw,AA,R,omega,theta,2);
    incvw = -eqnvw/jacvw(2);
    vw = vw + incvw;
    iter = iter + 1;
  end
  % average initial wind speed [p.u.]
  DAE.x(getidx(Wind,a.wind(i))) = vw/getvw(Wind,a.wind(i));
  % find & delete static generators
  if ~fm_rmgen(a.u(i)*a.bus(i)), check = 0; end
end

DAE.x(a.idr) = a.u.*DAE.x(a.idr);
DAE.x(a.iqr) = a.u.*DAE.x(a.iqr);
DAE.x(a.omega_m) = a.u.*DAE.x(a.omega_m);
DAE.x(a.theta_p) = a.u.*DAE.x(a.theta_p);

if ~check
  fm_disp('Doubly fed induction generators cannot be properly initialized.')
else
  fm_disp(['Doubly fed induction generators initialized.'])
end

