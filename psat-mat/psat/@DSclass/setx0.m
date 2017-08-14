function a = setx0(a)

global DAE

if ~a.n, return, end

delta = a.u.*DAE.x(a.delta);
omega = a.u.*DAE.x(a.omega);
Tm = a.u.*DAE.y(a.pm);

K12 = a.con(:,14);
K23 = a.con(:,15);
K34 = a.con(:,16);

DAE.x(a.omega_HP) = omega;
DAE.x(a.omega_IP) = omega;
DAE.x(a.omega_LP) = omega;
DAE.x(a.omega_EX) = omega;

DAE.x(a.delta_EX) = delta;
DAE.x(a.delta_LP) = (Tm+K34.*delta)./K34;
DAE.x(a.delta_IP) = (Tm+K23.*DAE.x(a.delta_LP))./K23;
DAE.x(a.delta_HP) = (Tm+K12.*DAE.x(a.delta_IP))./K12;

fm_disp('Initialization of Dynamic Shafts completed.')
