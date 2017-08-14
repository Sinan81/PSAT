function Fxcall(a)

global DAE Settings Wind

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

vdr = -rr.*idr+(1-omega_m).*(a33.*iqr+xm.*iqs);
vqr = -rr.*iqr-(1-omega_m).*(a33.*idr+xm.*ids);

iomega = 1./(omega_m+(~a.u));
Vwrate = getvw(Wind,a.wind);
Vw = vw.*Vwrate;
dPwdx = windpower(a,rho,Vw,A,R,~a.u+omega_m,theta_p,2)./Settings.mva/1e6;
Pw = ng.*windpower(a,rho,Vw,A,R,~a.u+omega_m,theta_p,1)/Settings.mva/1e6;
Tm = Pw.*iomega;
iqrsign = ones(a.n,1);
w21 = 2*omega_m-1;
idx = find(w21 <= 0 | w21 >= 1);
if ~isempty(idx), iqrsign(idx) = -1; end
Tsp = a.con(:,3).*min(w21,1).*iomega/Settings.mva;
Tsp = max(Tsp,0);

slip = 1-omega_m;
iqr_min = -a.con(:,3)/Settings.mva;

% d f / d y
% -----------

idsv =  a13.*st  - a23.*ct;
idst =  a13.*vqs - a23.*vds;
iqsv = -a23.*st  - a13.*ct;
iqst = -a23.*vqs - a13.*vds;

ot = xm.*(idr.*iqst-iqr.*idst).*i2Hm;
ov = xm.*(idr.*iqsv-iqr.*idsv).*i2Hm;
iqrv = (xs+xm).*Tsp./Te./V./V./xm;

DAE.Fy = DAE.Fy + sparse(a.omega_m,a.bus, ot,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.omega_m,a.vbus,ov,DAE.n,DAE.m);

% d g / d x
% -----------

idsidr = -a23.*xm;
idsiqr =  a13.*xm;
iqsidr = -a13.*xm;
iqsiqr = -a23.*xm;

vdridr = -rr + slip.*xm.*iqsidr;
vdriqr = slip.*(a33 + xm.*iqsiqr);
vqriqr = -rr - slip.*xm.*idsiqr;
vqridr = -slip.*(a33 + xm.*idsidr);

vdrom = -(a33.*iqr+xm.*iqs);
vqrom = a33.*idr+xm.*ids;

pidr = vds.*idsidr + vqs.*iqsidr + idr.*vdridr + vdr + iqr.*vqridr;
piqr = vds.*idsiqr + vqs.*iqsiqr + idr.*vdriqr + vqr + iqr.*vqriqr;
pom = idr.*vdrom + iqr.*vqrom;
qidr = -xm.*V./a.dat(:,1);

DAE.Gx = DAE.Gx - sparse(a.bus,a.omega_m,a.u.*pom,DAE.m,DAE.n);

% d f / d x
% -----------

oidr = xm.*(idr.*iqsidr+iqs-iqr.*idsidr).*i2Hm;
oiqr = xm.*(idr.*iqsiqr-ids-iqr.*idsiqr).*i2Hm;

% mechanical equation
% -------------------
DAE.Fx = DAE.Fx + sparse(a.omega_m,a.omega_m,-(~a.u)+(ng.*dPwdx(:,1)-Tm).*i2Hm.*iomega,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_m,getidx(Wind,a.wind),Vwrate.*ng.*dPwdx(:,2).*i2Hm.*iomega,DAE.n,DAE.n);

% pitch angle control equation
% ----------------------------
z = theta_p > 0 & a.u;
DAE.Fx = DAE.Fx - sparse(a.theta_p,a.theta_p,1./Tp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.theta_p,a.omega_m,z.*Kp./Tp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_m,a.theta_p,z.*ng.*dPwdx(:,3).*i2Hm.*iomega,DAE.n,DAE.n);

% speed control equation
% ----------------------
kiqr = -iqrsign.*(xs+xm)./V./xm./Te;
tspo = 2*a.con(:,3)/Settings.mva;
idx = find(Tsp == 0 & w21 >= 1);

%DAE.f(a.iqr) = a.u.*(-(xs+xm).*pwa./V./xm.*iomega-iqr-a.dat(:,7))./Te;
iqrp = -(xs+xm)./V./xm./Te.*iomega;
iqrw = (xs+xm).*pwa./V./xm./Te.*iomega.*iomega;

if ~isempty(idx), tspo(idx) = 0; end
iqr_max = a.dat(:,8);
iqr_min = a.dat(:,9);
z = iqr > iqr_min & iqr < iqr_max & a.u;
DAE.Fx = DAE.Fx - sparse(a.iqr,a.iqr,1./Te,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.iqr,a.omega_m,z.*iqrw,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_m,a.iqr,z.*oiqr,DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(a.iqr,a.vbus,z.*iqrv,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.iqr,a.pwa,z.*iqrp,DAE.n,DAE.m);
DAE.Gx = DAE.Gx - sparse(a.bus,a.iqr,z.*piqr,DAE.m,DAE.n);

% voltage control equation
% ------------------------
idr_max = a.dat(:,10);
idr_min = a.dat(:,11);
z = idr > idr_min & idr < idr_max & a.u;
DAE.Fx = DAE.Fx + sparse(a.idr,a.idr,-1,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_m,a.idr,z.*oidr,DAE.n,DAE.n);
DAE.Fy = DAE.Fy + sparse(a.idr,a.vbus,z.*(Kv-1./xm),DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(a.idr,a.vref,z.*Kv,DAE.n,DAE.m);
DAE.Gx = DAE.Gx - sparse(a.bus,a.idr,z.*pidr,DAE.m,DAE.n);
DAE.Gx = DAE.Gx - sparse(a.vbus,a.idr,z.*qidr,DAE.m,DAE.n);

%sparse(a.pwa, 1, a.con(:,3).*max(min(2*omega_m-1,1),0)/Settings.mva - pwa, DAE.m, 1);

% power reference equation
% ------------------------
z = omega_m > 0.5 & omega_m < 1;
DAE.Gx = DAE.Gx + sparse(a.pwa, a.omega_m, 2*z.*a.con(:,3)/Settings.mva, DAE.m, DAE.n);
