function gcall(a)

global DAE Settings
persistent vcont

if ~a.n, return, end

k = 0.995*3*sqrt(2)/pi;
c = 3/pi;

Idc = a.u.*DAE.x(a.Idc);
xr = a.u.*DAE.x(a.xr);
xi = a.u.*DAE.x(a.xi);

phir = a.u.*DAE.y(a.phir);
phii = a.u.*DAE.y(a.phii);
Vrdc = a.u.*DAE.y(a.Vrdc);
Vidc = a.u.*DAE.y(a.Vidc);

ur = Vrdc > 0.9;
ui = ~ur;

cosa = min(DAE.y(a.cosa),a.dat(:,3));
cosa = a.u.*ur.*max(cosa,a.dat(:,4)) + ui.*a.dat(:,3);
cosg = min(DAE.y(a.cosg),a.dat(:,5));
cosg = a.u.*ui.*max(cosg,a.dat(:,6)) + ur.*a.dat(:,5);

if ~Settings.init
  vcont = 2*ur + ui;
end

check = 2*ur + ui;

for i=1:a.n,
  if check(i) == 1 && vcont(i) == 2,
    vcont(i) = 1;
    cosg(i) = 0.5*(a.dat(i,5)+a.dat(i,6));
  end
  if check(i) == 2 && vcont(i) == 1
    vcont(i) = 2;
    cosa(i) = 0.5*(a.dat(i,3)+a.dat(i,4));
  end
end

yr = min(DAE.y(a.yr),a.con(:,21));
yr = a.u.*max(yr,a.con(:,22));
yi = min(DAE.y(a.yi),a.con(:,23));
yi = a.u.*max(yi,a.con(:,24));

V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);

xtr = a.con(:,9);
xti = a.con(:,10);
mr = a.con(:,11);
mi = a.con(:,12);
Kp = a.con(:,14);

I0 = a.con(:,26);
P0 = a.con(:,27);
V0 = a.con(:,28);
uI = a.u.*a.dat(:,9);
uP = a.u.*a.dat(:,10);
uV = a.u.*a.dat(:,11);

za = cosa < a.dat(:,3) & cosa > a.dat(:,4); 
zg = cosg < a.dat(:,5) & cosg > a.dat(:,6);
zr = yr < a.con(:,21) & yr > a.con(:,22); 
zi = yi < a.con(:,23) & yi > a.con(:,24); 

DAE.g = DAE.g ...
        + sparse(a.bus1,1,Vrdc.*Idc,DAE.m,1) ...
        - sparse(a.bus2,1,Vidc.*Idc,DAE.m,1) ...
        + sparse(a.v1,1,k*V1.*mr.*Idc.*sin(phir),DAE.m,1) ...
        + sparse(a.v2,1,k*V2.*mi.*Idc.*sin(phii),DAE.m,1) ...
        + sparse(a.cosa,1,za.*(xr+Kp.*(yr-(uI+uP).*Idc-uV.*Vrdc)-cosa),DAE.m,1) ...
        + sparse(a.Vrdc,1,k*V1.*cosa.*mr-c*xtr.*Idc-Vrdc,DAE.m,1) ...
        + sparse(a.phir,1,Vrdc-k*mr.*V1.*cos(phir),DAE.m,1) ...
        + sparse(a.yr,1,zr.*(uI.*I0+uP.*P0./(~a.u+Vrdc)+uV.*V0-yr),DAE.m,1) ...
        + sparse(a.cosg,1,zg.*(xi+Kp.*((uI+uP).*Idc+uV.*Vidc-yi)-cosg),DAE.m,1) ...
        + sparse(a.Vidc,1,k*V2.*cosg.*mi-c*xti.*Idc-Vidc,DAE.m,1) ...
        + sparse(a.phii,1,Vidc-k*mi.*V2.*cos(phii),DAE.m,1) ...
        + sparse(a.yi,1,zi.*(uI.*I0+uP.*P0./(~a.u+Vidc)+uV.*V0-yi),DAE.m,1);

DAE.y(a.cosa) = cosa;
DAE.y(a.cosg) = cosg;
DAE.y(a.yr) = yr;
DAE.y(a.yi) = yi;
