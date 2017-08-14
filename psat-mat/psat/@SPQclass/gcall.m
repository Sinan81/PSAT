function gcall(a)

global DAE 

if ~a.n, return, end


id = DAE.x(a.id);
iq = DAE.x(a.iq);


V = DAE.y(a.vbus);
t = DAE.y(a.bus);
st = sin(t);
ct = cos(t);


vd = -V.*st;
vq =  V.*ct;

p = vd.*id + vq.*iq;
q = vq.*id - vd.*iq;

DAE.g = DAE.g ...
        - sparse(a.bus,1, a.u.*p,DAE.m,1) ...
        - sparse(a.vbus,1, a.u.*q,DAE.m,1);
