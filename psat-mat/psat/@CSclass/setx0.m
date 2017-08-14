function a = setx0(a)

global Bus DAE Settings Wind

if ~a.n, return, end

check = 1;
Wn = 2*pi*Settings.freq;
V = DAE.y(a.vbus);
rho = getrho(Wind,a.wind);

% Constants
% x0
a.dat(:,1) =  a.con(:,7) + a.con(:,10);
% x'
a.dat(:,2) =  a.con(:,7) + a.con(:,10).*a.con(:,9)./ ...
    (a.con(:,10)+a.con(:,9));
% T'0
a.dat(:,3) = (a.con(:,10)+a.con(:,9))./a.con(:,8)/Wn;
% 1/(2*Hwr)
a.dat(:,4) = 1./(2*a.con(:,11));
% 1/(2*Hm)
a.dat(:,5) = 1./(2*a.con(:,12));
% 4*R*pi*f/p
a.dat(:,6) = 2*Wn*a.con(:,14)./a.con(:,15).*a.con(:,17);
% A
a.dat(:,7) = pi*a.con(:,14).*a.con(:,14);

% Initialization of state variables
Pc = Bus.Pg(a.bus);
Qc = Bus.Qg(a.bus);
Vc = DAE.y(a.vbus);
ac = DAE.y(a.bus);

vr = -Vc.*sin(ac);
vm =  Vc.*cos(ac);

for i = 1:a.n

  % parameters
  Vr = vr(i);
  Vm = vm(i);
  Rs = a.con(i,6);
  X0 = a.dat(i,1);
  X1 = a.dat(i,2);
  T10 = a.dat(i,3);
  Pg = Pc(i);
  Qg = Qc(i);
  
  eqn = ones(5,1);
  inc = ones(5,1);
  jac = zeros(5,5);
  
  jac(1,1) = Vr;
  jac(1,2) = Vm;
  jac(2,1) = -Rs;
  jac(2,2) = X1;
  jac(2,3) = 1;
  jac(3,1) = -X1;
  jac(3,2) = -Rs;
  jac(3,4) = 1;
  jac(4,2) = (X0-X1)/T10;
  jac(4,3) = -1/T10;
  jac(5,1) = -(X0-X1)/T10;
  jac(5,4) = -1/T10;
  
  % variables: x(1) = ir
  %            x(2) = im
  %            x(3) = e'r
  %            x(4) = e'm
  %            x(5) = sigma
  % first guess
  x = jac([1:5],[1:4])\[Pg;Vr;Vm;0;0];
  x(5) = 0;
  
  iter = 0;
  
  while max(abs(inc)) > 1e-5
    
    if iter > 20
      fm_disp(['Initialization of constant speed wind turbine #',...
               num2str(i),' failed (convergence problem).'])
      break
    end
    
    eqn(1) = Vr*x(1) + Vm*x(2) - Pg;
    eqn(2) = x(3) - Vr - Rs*x(1) + X1*x(2);
    eqn(3) = x(4) - Vm - Rs*x(2) - X1*x(1);
    eqn(4) =  Wn*x(5)*x(4) - (x(3)-(X0-X1)*x(2))/T10;
    eqn(5) = -Wn*x(5)*x(3) - (x(4)+(X0-X1)*x(1))/T10;
    
    jac(4,4) =  Wn*x(5);
    jac(4,5) =  Wn*x(4);
    jac(5,3) = -Wn*x(5);
    jac(5,5) = -Wn*x(3);
    
    inc = -jac\eqn;
    x = x + inc;
    iter = iter + 1;
    
  end
  
  Qg = Vm*x(1)-Vr*x(2);
  Te = x(3)*x(1)+x(4)*x(2);

  % shunt capacitor
  a.dat(i,8) = (Qc(i)-Qg)/V(i)/V(i);
  
  % wind turbine state variables
  DAE.x(a.e1r(i)) = x(3);
  DAE.x(a.e1m(i)) = x(4);
  DAE.x(a.omega_m(i)) = 1-x(5);
  DAE.x(a.gamma(i)) = Te/a.con(i,13);
  DAE.x(a.omega_t(i)) = DAE.x(a.omega_m(i));
  
  % wind power
  Pw = Te*DAE.x(a.omega_m(i))/a.con(i,18);
  if Pg < 0
    fm_disp([' * * Turbine power is negative at bus <',Bus.names{a.bus(i)},'>.'])
    fm_disp(['     Wind speed <',num2str(a.wind(i)),'> cannot be initilized.'])
    DAE.x(getidx(Wind,a.wind(i))) = 1;
    continue
  end
  % wind speed
  iter = 0;
  incvw = 1;
  eqnvw = 1;
  R = a.dat(i,6);
  A = a.dat(i,7);
  
  vw = 0.9*getvw(Wind,a.wind(i));
  
  while abs(eqnvw) > 1e-8
    if iter > 20
      wspeed = num2str(a.wind(i));
      fm_disp([' * * Initialization of wind speed <', ...
               wspeed, '> failed (convergence problem).'])
      fm_disp(['     Tip: Try increasing the nominal wind speed <',wspeed,'>.'])
      check = 0;
      break
    end
    eqnvw = windpower(a,rho(i),vw,A,R,DAE.x(a.omega_m(i)),1,1)-Pw*Settings.mva*1e6;
    jacvw = windpower(a,rho(i),vw,A,R,DAE.x(a.omega_m(i)),1,2);
    incvw = -eqnvw/jacvw(2);
    %disp([eqnvw+Pw*a.con(i,3),incvw])
    vw = vw + incvw;
    %disp([vw,iter]);
    iter = iter + 1;
  end
  DAE.x(getidx(Wind,a.wind(i))) = vw/getvw(Wind,a.wind(i));
  % find & delete static generators
  if ~fm_rmgen(a.u(i)*a.bus(i)), check = 0; end
end

DAE.x(a.e1r) = a.u.*DAE.x(a.e1r);
DAE.x(a.e1m) = a.u.*DAE.x(a.e1m);
DAE.x(a.omega_m) = a.u.*DAE.x(a.omega_m);
DAE.x(a.gamma) = a.u.*DAE.x(a.gamma);
DAE.x(a.omega_t) = a.u.*DAE.x(a.omega_t);

% random initial phase angle for shadow tower effect
%a.dat(:,9) = 2*pi*rand(a.n,1);

if ~check
  fm_disp('Constant speed wind turbine cannot be properly initialized.')
else
  fm_disp(['Initialization of constant speed wind turbines completed.'])
end
