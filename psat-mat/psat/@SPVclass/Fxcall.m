function Fxcall(a)

global DAE Settings PV

if ~a.n, return, end


btx1 = DAE.x(a.btx1);

bt_Pref = a.con(:,2)./Settings.mva;
bt_vref = DAE.y(a.vref);

Tp = a.con(:,4);
Tq = a.con(:,5);

bt_kv = a.con(:,6);
bt_ki = a.con(:,7);

V = DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);



vd = -V.*st;
vq =  V.*ct;



% d f / d y
% -----------

btxdv = -bt_ki;

idv = - (ct.* (btx1 + bt_kv.*bt_vref) - bt_Pref.*st)./V ./V ./Tp;
idtet = -(st.*(btx1 + bt_kv.*(bt_vref - V)) + bt_Pref.*ct)./V ./Tp;
iqv = - (bt_Pref.*ct + st.*(bt_kv.*bt_vref))./V ./V ./Tq;
iqtet = (ct.*(btx1 + bt_kv.*(bt_vref - V)) - bt_Pref.*st)./V ./Tq;

DAE.Fy = DAE.Fy + sparse(a.btx1,a.vbus, a.u.*btxdv,DAE.n,DAE.m);
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
didbtx = ct ./ (V.*Tp);
diqbtx = st ./ (V.*Tq);

DAE.Fx = DAE.Fx + sparse(a.id,a.btx1,a.u.*didbtx,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.iq,a.btx1,a.u.*diqbtx,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.id,a.id,a.u.*1./Tp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.iq,a.iq,a.u.*1./Tq,DAE.n,DAE.n);


% 
% % voltage control equation
% % ------------------------

btqm = PV.store;
btx1_max = btqm(1,6);
btx1_min = btqm(1,7);
z = btx1 > btx1_min & btx1 < btx1_max & a.u;

btxdvref = bt_ki;
idvref = (ct.* bt_kv) ./V ./Tp;
iqvref = (st.* bt_kv) ./V ./Tq;

DAE.Fy = DAE.Fy + sparse(a.btx1,a.vref, z.*btxdvref,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.id,a.vref, a.u.*idvref,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.iq,a.vref,a.u.*iqvref,DAE.n,DAE.m);

