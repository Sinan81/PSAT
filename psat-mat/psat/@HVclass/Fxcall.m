function Fxcall(a)

global DAE

if ~a.n, return, end

k = 0.995*3*sqrt(2)/pi;
c = 3/pi;

Idc = DAE.x(a.Idc);
xr = DAE.x(a.xr);
xi = DAE.x(a.xi);

cosa = DAE.y(a.cosa);
cosg = DAE.y(a.cosg);
phir = DAE.y(a.phir);
phii = DAE.y(a.phii);
Vrdc = DAE.y(a.Vrdc);
Vidc = DAE.y(a.Vidc);
yr = DAE.y(a.yr);
yi = DAE.y(a.yi);
V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);

xtr = a.con(:,9);
xti = a.con(:,10);
mr  = a.con(:,11);
mi  = a.con(:,12);
Ki  = a.con(:,13);
Kp  = a.con(:,14);
Rdc = a.dat(:,1);
Tdc = a.dat(:,2);

za = cosa < a.dat(:,3) & cosa > a.dat(:,4) & a.u; 
zg = cosg < a.dat(:,5) & cosg > a.dat(:,6) & a.u; 
zr = yr < a.con(:,21) & yr > a.con(:,22) & a.u; 
zi = yi < a.con(:,23) & yi > a.con(:,24) & a.u; 
zxr = xr < a.dat(:,3) & xr > a.dat(:,4) & a.u; 
zxi = xi < a.dat(:,5) & xi > a.dat(:,6) & a.u; 

V0 = a.con(:,28);
uI = a.u.*(a.dat(:,9)+a.dat(:,10));
uV = a.u.*a.dat(:,11);

DAE.Fx = DAE.Fx ...
         - sparse(a.Idc,a.Idc,1./Tdc,DAE.n,DAE.n) ...
         - sparse(a.xr,a.Idc,zxr.*Ki.*uI,DAE.n,DAE.n) ...
         - sparse(a.xr,a.xr,~zxr+1e-6,DAE.n,DAE.n) ...
         - sparse(a.xi,a.xi,~zxi+1e-6,DAE.n,DAE.n) ...
         + sparse(a.xi,a.Idc,zxi.*Ki.*uI,DAE.n,DAE.n);

DAE.Fy = DAE.Fy ...
         + sparse(a.Idc,a.Vrdc,a.u./Rdc./Tdc,DAE.n,DAE.m) ...
         - sparse(a.Idc,a.Vidc,a.u./Rdc./Tdc,DAE.n,DAE.m) ...
         + sparse(a.xr,a.yr,zxr.*zr.*Ki,DAE.n,DAE.m) ...
         - sparse(a.xi,a.yi,zxi.*zi.*Ki,DAE.n,DAE.m) ...
         - sparse(a.xr,a.Vrdc,zxr.*Ki.*uV,DAE.n,DAE.m) ...
         + sparse(a.xi,a.Vidc,zxi.*Ki.*uV,DAE.n,DAE.m);

DAE.Gx = DAE.Gx ...
         + sparse(a.bus1,a.Idc,Vrdc,DAE.m,DAE.n) ...
         - sparse(a.bus2,a.Idc,Vidc,DAE.m,DAE.n) ...
         + sparse(a.v1,a.Idc,k*V1.*mr.*sin(phir),DAE.m,DAE.n) ...
         + sparse(a.v2,a.Idc,k*V2.*mi.*sin(phii),DAE.m,DAE.n) ...
         + sparse(a.cosa,a.xr,zxr.*za,DAE.m,DAE.n) ...
         - sparse(a.cosa,a.Idc,za.*Kp.*uI,DAE.m,DAE.n) ...
         - sparse(a.Vrdc,a.Idc,c*a.u.*xtr,DAE.m,DAE.n) ...
         + sparse(a.cosg,a.xi,zxi.*zg,DAE.m,DAE.n) ...
         + sparse(a.cosg,a.Idc,zg.*Kp.*uI,DAE.m,DAE.n) ...
         - sparse(a.Vidc,a.Idc,c*a.u.*xti,DAE.m,DAE.n);
