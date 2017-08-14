function fcall(p)

global DAE

if ~p.n, return, end

% COMO YA HICE EN EL g.call HAY QUE DEFINIR TODAS LAS VARIABLES Y
% MOSTRAR SU ESTADO ACTUAL CON EL DAE.x O DAE.y

% VARIABLES DE ESTADO INTERNAS

Dfm = DAE.x(p.Dfm);
x = DAE.x(p.x);
csi = DAE.x(p.csi);
pfw = DAE.x(p.pfw);
pwa = DAE.y(p.pwa);

% VARIABLES DE ESTADO Y ALGEBRAICAS? EXTERNAS.

we = DAE.x(p.we);
Df = DAE.x(p.Df);

% DE NUEVO HAY QUE DEFINIR LOS PARAMETROS Y SU NUMERO DE COLUMNA.

Tr = p.con(:, 3);
Tw = p.con(:, 4);
R = p.con(:, 5);
we_max = p.con(:, 6);
we_min = p.con(:, 7);
KI = p.con(:, 8);
KP = p.con(:, 9);
csi_max = p.con(:, 10);
csi_min = p.con(:, 11);
TA = p.con(:, 12);
pw_max = p.con(:, 13);
pw_min = p.con(:, 14);

we_ref = p.dat(:, 1);

% Ecuaciones
%
% (2)  diff(deltafm') - diff(deltafm) = deltafm'/Tw
% (3)  diff(deltaf) = (deltafm - deltaf)/Tr
% (4)  diff(pci) = (kci*pf-pci)/Tci
% (8)  diff(pfw) = (pfw*-pfw)/Ta
% (9)  diff(kcn*pf*-pcn)/Tcn
% (12) diff(we)= [1/(2*He*we)]*(pin-pout)

% AHORA HACIENDO USO DEL DAE.f SE ESCRIBEN LAS ECUACIONES
% DIFERENCIALES.

DAE.f(p.Dfm) = p.u.*(Df - 1 - Dfm)./Tr;
DAE.f(p.x) = -p.u.*(Dfm + x)./Tw;
DAE.f(p.csi) = p.u.*KI.*(we_ref - we);
DAE.f(p.pfw) = p.u.*(pwa - pfw)./TA;

% dejo al anti windup como estaba.
% anti-windup limiter
fm_windup(p.csi, csi_max, csi_min, 'f')
