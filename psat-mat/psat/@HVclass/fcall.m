function fcall(a)

global DAE

if ~a.n, return, end

Idc = DAE.x(a.Idc);
xr = DAE.x(a.xr);
xi = DAE.x(a.xi);
Vrdc = DAE.y(a.Vrdc);
Vidc = DAE.y(a.Vidc);
yr = DAE.y(a.yr);
yi = DAE.y(a.yi);
V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);

Ki = a.u.*a.con(:,13);
Rdc = a.dat(:,1);
Tdc = a.dat(:,2);

uI = a.u.*(a.dat(:,9)+a.dat(:,10));
uV = a.u.*a.dat(:,11);

DAE.f(a.Idc) = a.u.*((Vrdc-Vidc)./Rdc-Idc)./Tdc;
DAE.f(a.xr) = Ki.*(yr-uI.*Idc-uV.*Vrdc);
DAE.f(a.xi) = Ki.*(uI.*Idc+uV.*Vidc-yi);

% anti-windup limiter
fm_windup(a.xr,a.dat(:,3),a.dat(:,4),'f')
fm_windup(a.xi,a.dat(:,5),a.dat(:,6),'f')
