function gcall(a)

global DAE

if ~a.n, return, end

id = DAE.x(a.Id);
iq = DAE.x(a.Iq);
V = a.u.*DAE.y(a.vbus);
theta = DAE.y(a.bus);
delta = DAE.x(a.delta);
cdt = cos(delta-theta);
sdt = sin(delta-theta);

DAE.g = DAE.g - sparse(a.bus,1,V.*sdt.*id+V.*cdt.*iq,DAE.m,1) ...
        - sparse(a.vbus,1,V.*cdt.*id-V.*sdt.*iq,DAE.m,1);
