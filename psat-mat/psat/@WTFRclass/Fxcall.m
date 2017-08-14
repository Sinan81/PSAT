function Fxcall(p)

global DAE 

if ~p.n, return, end

%COMO EN TODOS LOS ANTERIORES DEFINIMOS TODAS LAS VARIABLES NECESARIAS

%INTERNAS DE ESTADO
Dfm = DAE.x(p.Dfm);
x = DAE.x(p.x);
csi = DAE.x(p.csi);
pfw = DAE.x(p.pfw);

%EXTERNAS 
we = DAE.x(p.we);
Df = DAE.x(p.Df);

%INTERNAS ALGEBRAICAS
pf1 = DAE.y(p.pf1);
pwa = DAE.y(p.pwa);
pout = DAE.y(p.pout);

%VARIABLES QUE HAY QUE INTRODUCIR
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
pfw_max = p.con(:, 13);
pfw_min = p.con(:, 14);

we_ref = p.dat(:, 1);

% remove d pref/ d omega_m from wind turbine gradients
DAE.Gx(p.pout, p.we) = diag((~p.u).*diag(DAE.Gx(p.pout,p.we)));

%AHORA EMPEZAMOS A HACER LAS DERIVADAS de las ecuaciones algebraicas
%A CONTINUACION COPIO LAS ECUACIONES PARA HACERLO SOBRE ELLAS
% sparse(p.pf1,  1, p.u.*(x + Dfm)./R - pf1, DAE.m, 1) ...
% sparse(p.pwa,  1, p.u.*(csi + KP.*(we_ref - we)) - pwa, DAE.m, 1) ...
% sparse(p.pout, 1, p.u.*(pfw - pout), DAE.m, 1);

z_csi = csi > csi_min & csi < csi_max & p.u;

%DERIVADA DE LA PRIMERA ECUACION CON RESPECTO A SUS DIFERENTES VARIABLES
DAE.Gx = DAE.Gx + sparse(p.pf1, p.x, p.u./R, DAE.m, DAE.n); 
DAE.Gx = DAE.Gx + sparse(p.pf1, p.Dfm, p.u./R, DAE.m, DAE.n);

%DERIVADA DE LA SEGUNDA ECUACION CON RESPECTO A SUS DIFERENTES VARIABLES
DAE.Gx = DAE.Gx + sparse(p.pwa, p.csi, z_csi, DAE.m, DAE.n);
DAE.Gx = DAE.Gx - sparse(p.pwa, p.we, p.u.*KP, DAE.m, DAE.n); 

%DERIVADA DE LA TERCERA ECUACION CON RESPECTO A SUS DIFERENTES VARIABLES
DAE.Gx = DAE.Gx + sparse(p.pout, p.pfw, p.u.*1, DAE.m, DAE.n);
%DAE.Gx = DAE.Gx - sparse(p.pout, p.pout, p.u.*1, DAE.m, DAE.n);
%DAE.Gx = DAE.Gx - sparse(p.pout, p.we, 0, DAE.m, DAE.n);

%AHORA EMPEZAMOS A HACER LAS DERIVADAS de las ecuaciones diferenciales
%A CONTINUACION COPIO LAS ECUACIONES PARA HACERLO SOBRE ELLAS
% DAE.f(p.Dfm) = p.u.*(Df - Dfm)./Tr;
% DAE.f(p.x) = -p.u.*(Dfm + x)./Tw;
% DAE.f(p.csi) = p.u.*KI.*(we_ref - we);
% DAE.f(p.pfw) = p.u.*(pwa - pwf)./TA;

%PRIMERA ECUACION
DAE.Fx = DAE.Fx - sparse(p.Dfm, p.Dfm, 1./Tr, DAE.n, DAE.n);
DAE.Fx = DAE.Fx + sparse(p.Dfm, p.Df, p.u./Tr, DAE.n, DAE.n);

%SEGUNDA ECUACION
DAE.Fx = DAE.Fx - sparse(p.x, p.Dfm, p.u./Tw, DAE.n, DAE.n);
DAE.Fx = DAE.Fx - sparse(p.x, p.x, 1./Tw, DAE.n, DAE.n);

%TERCERA ECUACION
DAE.Fx = DAE.Fx - sparse(p.csi, p.we, z_csi.*KI, DAE.n, DAE.n);

%CUARTA ECUACION
DAE.Fx = DAE.Fx - sparse(p.pfw, p.pfw, 1./TA, DAE.n, DAE.n);
DAE.Fy = DAE.Fy + sparse(p.pfw, p.pwa, p.u./TA, DAE.n, DAE.m);
