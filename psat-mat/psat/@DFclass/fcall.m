function fcall(a)

global DAE Wind Settings

if ~a.n, return, end

omega_m = DAE.x(a.omega_m);
theta_p = DAE.x(a.theta_p);
idr = DAE.x(a.idr);
iqr = DAE.x(a.iqr);
vw = DAE.x(getidx(Wind,a.wind));
rho = getrho(Wind,a.wind);

pwa = DAE.y(a.pwa);
V = DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);

rs = a.con(:,6);
xs = a.con(:,7);
rr = a.con(:,8);
xr = a.con(:,9);
xm = a.con(:,10);

i2Hm = a.u.*a.dat(:,3);
Kp = a.con(:,12);
Tp = a.con(:,13);
Kv = a.con(:,14);
Te = a.con(:,15);
R = a.dat(:,4);
A = a.dat(:,5);
ng = a.con(:,24);

as = rs.^2+a.dat(:,1).^2;
a13 = rs./as;
a23 = a.dat(:,1)./as;
a33 = a.dat(:,2);

vds = -V.*st;
vqs =  V.*ct;

ids =  -a13.*(vds-xm.*iqr)-a23.*(vqs+xm.*idr);
iqs =   a23.*(vds-xm.*iqr)-a13.*(vqs+xm.*idr);

% wind speed in m/s
iomega = 1./(omega_m+(~a.u));
Vw = vw.*getvw(Wind,a.wind);
Pw = ng.*windpower(a,rho,Vw,A,R,~a.u+omega_m,theta_p,1)/Settings.mva/1e6;
% mechanical torque
Tm = Pw.*iomega;

% motion equation
DAE.f(a.omega_m) = (Tm-xm.*(iqr.*ids-idr.*iqs)).*i2Hm;

% speed control equations
%Pm = a.con(:,3).*max(min(2*omega_m-1,1),0)/Settings.mva;
DAE.f(a.iqr) = a.u.*(-(xs+xm).*pwa./V./xm.*iomega-iqr-a.dat(:,7))./Te;

% voltage control equation
DAE.f(a.idr) = a.u.*(Kv.*(V-DAE.y(a.vref))-V./xm-idr);

% pitch control equation
% vary the pitch angle only by steps of 1% of the fn
phi = round(1000*(~a.u+omega_m-1))/1000;
DAE.f(a.theta_p) = a.u.*(Kp.*phi-theta_p)./Tp;

% anti-windup limiter
fm_windup(a.iqr,a.dat(:,8),a.dat(:,9),'f')
fm_windup(a.idr,a.dat(:,10),a.dat(:,11),'f')
fm_windup(a.theta_p,Inf,0,'f')
