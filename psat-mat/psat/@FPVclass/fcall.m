function fcall(a)

global DAE

Ig = DAE.y(a.Ig);
I0 = DAE.y(a.I0);
IL = DAE.y(a.IL);
Vg = DAE.y(a.Vg);
Eg = DAE.y(a.Eg);
G = DAE.y(a.G);
Ta = DAE.y(a.Ta);
Tc = DAE.x(a.Tc);

Pn=a.con(:,2);      %   Power rating                    W	60
Vn=a.con(:,3);      %	Voltage rating                  V	16.8
Isc=a.con(:,4);     %   Short Circuit current           A	3.80
Rs=a.con(:,5);      %	Serial Resistence               Ohm	
Rp=a.con(:,6);      %	Shunt Resistance                Ohm	
agap=a.con(:,7);    % 	Thermal coeficient              eV/K	
bgap=a.con(:,8);    %	Thermal coeficient              K	
md=a.con(:,9);      %	Diode factor	-               1.2
Jsc=a.con(:,10);    %	Short circuit surrent density	A/cm2	
aJsc=a.con(:,11);   %	Short circuit density coeficient	A/ºC·cm2	
Eg0=a.con(:,12);    % 	Energy Band Gap at 0K           eV	1.12
Ncp=a.con(:,13);    %	Nº of parallel cells            int	1
Ncs=a.con(:,14);    %	Nº of serial cells              int	36
Ac=a.con(:,15);     %	Cell area                       cm2	
mc=a.con(:,16);     %	masa de célula                  kg	
C=a.con(:,17);      %	Capacidad calorífica módulo		
A=a.con(:,18);      %	Area modulo		
h = a.con(:,19);    %   coeficiente conveccion
Ta = a.con(:,20);   %   ambient temperature

Eg1 = a.dat(:, 1); 
Vt = a.dat(:, 2);
Dconst = a.dat(:, 3); 

DAE.f(DAE.Tc) = a.u.*(G - A.*h.*(Tc - Ta) - Vg.*Ig)./mc./C;

