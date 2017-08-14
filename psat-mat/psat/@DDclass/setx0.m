function a = setx0(a)

global Bus DAE Settings Wind

if ~a.n, return, end

check = 1;

rho = getrho(Wind,a.wind);
Kv = a.con(:,13);
rs = a.con(:,6);
xd = a.con(:,7);
xq = a.con(:,8);
psip = a.con(:,9);

%check time constants
idx = find(a.con(:,10) == 0);
if idx
  warn(a,idx, 'Inertia Hm cannot be zero. Hm = 2.5 s will be used.'),
  a.con(idx,10) = 2.5;
end

idx = find(a.con(:,12) == 0);
if idx
  warn(a,idx, 'Time constant Tp cannot be zero. Tp = 0.001 s will be used.'),
  a.con(idx,12) = 0.001;
end

idx = find(a.con(:,14) == 0);
if idx
  warn(a,idx, 'Time constant Tv cannot be zero. Tv = 0.001 s will be used.'),
  a.con(idx,14) = 0.001;
end

%idx = find(a.con(:,16) == 0);
%if idx
%  warn(a,idx, 'Time constant Teq cannot be zero. Teq = 0.001 s will be used.'),
%  a.con(idx,16) = 0.001;
%end

idx = find(a.con(:,15) == 0);
if idx
  warn(a,idx, 'Time constant Tep cannot be zero. Tep = 0.001 s will be used.'),
  a.con(idx,15) = 0.001;
end

% Constants
% etaGB*4*R*pi*f/p
a.dat(:,1) = 4*pi*Settings.freq*a.con(:,17)./a.con(:,18).*a.con(:,20);
% A
a.dat(:,2) = pi*a.con(:,17).*a.con(:,17);

% Initialization of state variables
Pc = Bus.Pg(a.bus);
Qc = Bus.Qg(a.bus);
Vc = DAE.y(a.vbus);
ac = DAE.y(a.bus);

vdc = -Vc.*sin(ac);
vqc =  Vc.*cos(ac);

for i = 1:a.n
  
  % idc
  DAE.x(a.idc(i)) = cos(ac(i))*(Qc(i)-Pc(i)*tan(ac(i)))/Vc(i);
  % Vref
  a.dat(i,3) =  DAE.x(a.idc(i))/Kv(i)+Vc(i);
  
  if Pc(i)*Settings.mva < a.con(i,3) && Pc(i) > 0
    omega_m = 0.5*Pc(i)*Settings.mva/a.con(i,3)+0.5;
  elseif Pc(i)*Settings.mva >= a.con(i,3)
    omega_m = 1;
  else
    omega_m = 0.5;
  end

  jac = zeros(4,4);
  jac(3,1) = -1;
  jac(3,3) = -rs(i);
  jac(3,4) = omega_m*xq(i);
  jac(4,2) = 1;
  jac(4,3) = omega_m*xd(i);
  jac(4,4) = rs(i);
  
  x = zeros(4,1);
  x(1) = 0.5;
  x(2) = psip(i);
  x(3) = Qc(i)/Vc(i);
  x(4) = Pc(i)/Vc(i);
  
  iter = 0;
  inc = Inf;
  
  while max(abs(inc)) > 1e-10
    
    if iter > 40
      fm_disp(['Initialization of direct drive syn. gen. #', num2str(i), ' failed.'])
      check = 0;
      break
    end
        
    eqn(1,1) = x(1)*x(3)+x(2)*x(4)-Pc(i);
    %eqn(2,1) = x(2)*x(3)-x(1)*x(4);
    eqn(2,1) = omega_m*x(4)*(psip(i)-xd(i)*x(3)) - Pc(i);
    eqn(3,1) = -x(1)-rs(i)*x(3)+omega_m*xq(i)*x(4);
    eqn(4,1) = x(2)+rs(i)*x(4)+omega_m*xd(i)*x(3)-omega_m*psip(i);
    
    jac(1,1) = x(3);
    jac(1,2) = x(4);
    jac(1,3) = x(1);
    jac(1,4) = x(2);
    %jac(2,1) = -x(4);
    %jac(2,2) = x(3);
    %jac(2,3) = x(2);
    %jac(2,4) = -x(1);
    jac(2,3) = -xd(i)*omega_m*x(4)*psip(i);
    jac(2,4) = omega_m*(psip(i)-xd(i)*x(3));
    
    inc = -jac\eqn;
    x = x + inc;
    %disp([x'; inc'])
    iter = iter + 1;
    
  end

  vds = x(1);
  vqs = x(2);
  ids = x(3);
  iqs = x(4);
  
  a.dat(i,4) = vqs*ids-vds*iqs; % initial Qs
  %omega_m = 1;
  %k = a.con(i,3)/Settings.mva;
  %omega_m = k/(2*k-iqs*(psip(i)-xd(i)*ids));
  
  % theta_p
  theta_p = a.con(i,11)*round(1000*(omega_m-1))/1000;
  theta_p = max(theta_p,0);
  
  % wind turbine state variables and constants
  DAE.y(a.ids(i)) = ids; % ids
  DAE.x(a.iqs(i)) = iqs; % iqs
  DAE.x(a.omega_m(i)) = omega_m;
  DAE.x(a.theta_p(i)) = theta_p;
  
  % electrical torque
  Tel = ((xq(i)-xd(i))*ids+psip(i))*iqs;
  
  % wind power [MW]
  Pw = Tel*omega_m*Settings.mva*1e6/a.con(i,25);
  if Pc(i) < 0
    fm_disp([' * * Turbine power is negative at bus <',Bus.names{a.bus(i)},'>.'])
    fm_disp(['     Wind speed <',num2str(a.wind(i)),'> cannot be initilized.'])
    DAE.x(getidx(Wind,a.wind(i))) = 1;
    continue
  end
  % wind speed
  iter = 0;
  incvw = 1;
  eqnvw = 1;
  R = a.dat(i,1);
  A = a.dat(i,2);
  % initial guess for wind speed
  vw = 0.9*getvw(Wind,a.wind(i));
  while abs(eqnvw) > 1e-7
    if iter > 50
      wspeed = num2str(a.wind(i));
      fm_disp([' * * Initialization of wind speed <', ...
               wspeed,'> failed (convergence problem).'])
      fm_disp(['     Tip: Try increasing the nominal wind speed <',wspeed,'>.'])
      check = 0;
      break
    end
    eqnvw = windpower(a,rho(i),vw,A,R,omega_m,theta_p,1)-Pw;
    jacvw = windpower(a,rho(i),vw,A,R,omega_m,theta_p,2);
    incvw = -eqnvw/jacvw(2);
    vw = vw + incvw;
    iter = iter + 1;
  end
  % average initial wind speed [p.u.]
  DAE.x(getidx(Wind,a.wind(i))) = vw/getvw(Wind,a.wind(i));
  % find & delete static generators
  if ~fm_rmgen(a.u(i)*a.bus(i)), check = 0; end
end

DAE.x(a.idc) = a.u.*DAE.x(a.idc);
DAE.y(a.ids) = a.u.*DAE.y(a.ids);
DAE.y(a.iqc) = a.u.*(Pc - vdc.*DAE.x(a.idc))./vqc;
DAE.x(a.iqs) = a.u.*DAE.x(a.iqs);
DAE.x(a.omega_m) = a.u.*DAE.x(a.omega_m);
DAE.x(a.theta_p) = a.u.*DAE.x(a.theta_p);
DAE.y(a.pwa) = a.u.*a.con(:,3).*max(min(2*DAE.x(a.omega_m)-1,1),0)/Settings.mva;

if ~check
  fm_disp('Direct drive synchronous generator cannot be properly initialized.')
else
  fm_disp('Initialization of direct drive synchronous generators completed.')
end
