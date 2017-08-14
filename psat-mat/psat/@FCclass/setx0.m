function a = setx0(a)

global Bus DAE

if ~a.n, return, end

Sn = a.con(:,2);
Vn = a.con(:,3);
Vb = DAE.y(a.vbus);
KH2 = a.con(:,6);
Kr = a.con(:,7);
KH2O = a.con(:,9);
KO2 = a.con(:,11);
rHO = a.con(:,12);
Uopt = a.con(:,14);
r = a.con(:,17);
N0 = a.con(:,18);
E0 = a.con(:,19);
RTon2F = a.con(:,20);
xt = a.con(:,26);
Km = a.con(:,27);

% Check time constants
a.con(:,5) = tc(a,a.con(:,5),0.001,'Te');
a.con(:,7) = tc(a,a.con(:,7),0.001,'TH2');
a.con(:,10) = tc(a,a.con(:,10),0.001,'TH2O');
a.con(:,12) = tc(a,a.con(:,12),0.001,'TO2');
a.con(:,15) = tc(a,a.con(:,15),0.001,'Tf');
a.con(:,28) = tc(a,a.con(:,28),0.001,'Tm');

% find & delete static generators
check = 1;
for j = 1:a.n
  if ~fm_rmgen(a.u(j)*a.bus(j)), check = 0; end
end

% Get generator powers
Pfc = Bus.Pg(a.bus);
Qfc = Bus.Qg(a.bus);

% Define reference active power
a.con(:,21) = Pfc;

% Fuel Cell stae variable initialization
DAE.x(a.Ik) = Sn.*Pfc./Vb./Vn;
Ik = DAE.x(a.Ik);
DAE.x(a.qH2) = 2*Kr.*Ik./Uopt;
qH2 = DAE.x(a.qH2);
DAE.x(a.pO2) = (qH2./rHO-Kr.*Ik)./KO2;
pO2 = DAE.x(a.pO2);
DAE.x(a.pH2) = (qH2 - 2*Kr.*Ik)./KH2;
pH2 = DAE.x(a.pH2);
DAE.x(a.pH2O) = 2*Kr.*Ik./KH2O;
pH2O = DAE.x(a.pH2O);
logarg = pH2.*sqrt(pO2)./pH2O;
DAE.x(a.Vk) = -r.*Ik./Vn + N0.*(E0+RTon2F.*log(logarg))./Vn;
Vk = DAE.x(a.Vk);

% Base power and voltage
a.con(:,23) = (Ik.*Vk.*Vn./Sn)./Pfc;
a.con(:,24) = Vb./Vk;

% Adjust value of control type
a.con(:,25) = ~a.con(:,25);
idx = find(a.con(:,25));
if idx, a.con(idx,25) = Vk(idx); end

% Initialize tap ratio
DAE.x(a.m) = sqrt(((xt./DAE.y(a.vbus)./Vk./a.con(:,24)).^2) ...
                     .*(Pfc.^2+(Qfc+(Vb.^2)./xt).^2));

% Define reference AC voltage
a.con(:,22) = Vb+DAE.x(a.m)./Km;

% take into account SOFC status
DAE.x(a.Ik) = a.u.*Ik;
DAE.x(a.qH2) = a.u.*qH2;
DAE.x(a.pO2) = a.u.*pO2;
DAE.x(a.pH2) = a.u.*pH2;
DAE.x(a.pH2O) = a.u.*pH2O;
DAE.x(a.Vk) = a.u.*Vk;
DAE.x(a.m) = a.u.*DAE.x(a.m) + ~a.u;

if ~check
  fm_disp('Fuel cells cannot be properly initialized.')
else
  fm_disp('Initialization of Solid Oxyde Fuel Cells completed.')
end

