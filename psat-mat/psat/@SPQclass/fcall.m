function fcall(a)

global DAE  Settings

if ~a.n, return, end

id = DAE.x(a.id);
iq = DAE.x(a.iq);

V = DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);

bt_Pref = a.con(:,2)./Settings.mva;
bt_Qref = a.con(:,3)./Settings.mva;

Tp = a.con(:,4);
Tq = a.con(:,5);


DAE.f(a.id) = a.u.*((bt_Qref.*ct - bt_Pref.*st)./V - id)./Tp;

DAE.f(a.iq) = a.u.*((bt_Pref.*ct + bt_Qref.*st)./V - iq)./Tq;


