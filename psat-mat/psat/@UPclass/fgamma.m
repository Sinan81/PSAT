function g = fgamma(a)

global DAE

V = DAE.y(a.v1).*exp(i*DAE.y(a.bus1)) - ...
    DAE.y(a.v2).*exp(i*DAE.y(a.bus2));

theta = angle(V)-pi/2;

g = atan2(DAE.x(a.vq),DAE.x(a.vp))+theta-DAE.y(a.bus1);
