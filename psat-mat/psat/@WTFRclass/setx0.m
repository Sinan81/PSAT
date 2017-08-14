function a = setx0(a)

global DAE Settings

if ~a.n, return, end

a.dat(:,1) = DAE.x(a.we); % omega ref.

DAE.x(a.pfw) = DAE.y(a.pout);
DAE.x(a.Dfm) = 0;
DAE.x(a.x) = 0;
DAE.x(a.csi) = DAE.y(a.pout);

DAE.y(a.pwa) = DAE.y(a.pout);
DAE.y(a.pf1) = 0;

Tr = a.con(:,3);
Tw = a.con(:,4);
Ta = a.con(:,13);

% check time constants
idx = find(Tr == 0);
if idx
  warn(a,idx, ['Time constant Tf cannot be zero. Tr = 0.001 ' ...
               's will be used.'])
end
a.con(idx,3) = 0.001;

idx = find(Tw == 0);
if idx
  warn(a,idx, ['Time constant Tw cannot be zero. Tw = 0.001 ' ...
               's will be used.'])
end
a.con(idx,4) = 0.001;

idx = find(Ta == 0);
if idx
  warn(a,idx, ['Time constant Tw cannot be zero. Ta = 0.001 ' ...
               's will be used.'])
end
a.con(idx,13) = 0.001;

fm_disp('Initialization of Wind Turbine Frequency Regulator completed.')

