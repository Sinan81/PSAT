function Fxcall(a)

global DAE Settings

if ~a.n, return, end


bt_Pref = a.con(:,2)./Settings.mva;
bt_Qref = a.con(:,3)./Settings.mva;

Tp = a.con(:,4);
Tq = a.con(:,5);


V = DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);

vd = -V.*st;
vq =  V.*ct;



% d f / d y
% -----------


idv = - (bt_Qref.*ct - bt_Pref.*st)./V ./V ./Tp;
idtet = -(bt_Qref.*st + bt_Pref.*ct)./V ./Tp;
iqv = - (bt_Pref.*ct + bt_Qref.*st)./V ./V ./Tq;
iqtet = (bt_Qref.*ct - bt_Pref.*st)./V ./Tq;

DAE.Fy = DAE.Fy + sparse(a.id,a.vbus, a.u.*idv,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.id,a.bus, a.u.*idtet,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.iq,a.vbus,a.u.*iqv,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.iq,a.bus, a.u.*iqtet,DAE.n,DAE.m);

% d g / d x
% -----------

dPid = vd;
dPiq = vq;
dQid = vq;
dQiq = -vd;

DAE.Gx = DAE.Gx - sparse(a.bus,a.id,a.u.*dPid,DAE.m,DAE.n);
DAE.Gx = DAE.Gx - sparse(a.bus,a.iq,a.u.*dPiq,DAE.m,DAE.n);
DAE.Gx = DAE.Gx - sparse(a.vbus,a.id,a.u.*dQid,DAE.m,DAE.n);
DAE.Gx = DAE.Gx - sparse(a.vbus,a.iq,a.u.*dQiq,DAE.m,DAE.n);


% d f / d x
% -----------

DAE.Fx = DAE.Fx - sparse(a.id,a.id,a.u.*1./Tp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.iq,a.iq,a.u.*1./Tq,DAE.n,DAE.n);
