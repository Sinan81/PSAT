function gcall(a)

global DAE Settings

if ~a.n, return, end

omega_m = DAE.x(a.omega_m);
idr = DAE.x(a.idr);
iqr = DAE.x(a.iqr);

pwa = DAE.y(a.pwa);
V = DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);

rs = a.con(:,6);
rr = a.con(:,8);
xm = a.con(:,10);

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

p = vds.*ids+vqs.*iqs+vdr.*idr+vqr.*iqr;
q = -V.*(xm.*idr+V)./a.dat(:,1);

DAE.g = DAE.g ...
        - sparse(a.bus,1, a.u.*p,DAE.m,1) ...
        - sparse(a.vbus,1, a.u.*q,DAE.m,1) ...
        + sparse(a.vref,1, a.u.*a.dat(:,6)-DAE.y(a.vref),DAE.m,1) ...
        + sparse(a.pwa, 1, a.u.*a.con(:,3).*max(min(2*omega_m-1,1),0)/Settings.mva - pwa, DAE.m, 1);
