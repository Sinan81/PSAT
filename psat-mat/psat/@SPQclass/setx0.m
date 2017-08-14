function a = setx0(a)

global Bus DAE 

if ~a.n, return, end

check = 1;

% bt_Pref = a.con(:,2)./Settings.mva;
% bt_Qref = a.con(:,3)./Settings.mva;

% Pc = Bus.Pg(a.bus);
% Qc = Bus.Qg(a.bus);
Vc = DAE.y(a.vbus);
ac = DAE.y(a.bus);

Vd = -Vc.*sin(ac);
Vq =  Vc.*cos(ac);
% 
% % Initialization of state variables

for i = 1:a.n
  
  % find & delete static generators
  if ~fm_rmgen(a.u(i)*a.bus(i)), check = 0; end
end

% state variables initialization
% id = bt_Qref;
% iq = bt_Pref;
% DAE.x(a.id) = a.u.*id;
% DAE.x(a.iq) = a.u.*iq;
idiq = [Vd Vq; Vq -Vd]\[Bus.Pg(a.bus);Bus.Qg(a.bus)];
id = idiq(1);
iq = idiq(2);

DAE.x(a.id) = a.u.*id;
DAE.x(a.iq) = a.u.*iq;


if ~check
  fm_disp('Solar photo-voltaic generators (PQ model) cannot be properly initialized.')
else
  fm_disp('Initialization of Solar Photo-Voltaic Generators (PQ model) completed.')
end

