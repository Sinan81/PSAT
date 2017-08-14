function gcall(a)

global DAE

if ~a.n, return, end

DAE.g = DAE.g ...
        - sparse(a.vbus,1,a.u.*DAE.x(a.ist).*DAE.y(a.vbus),DAE.m,1) ...
        + sparse(a.vref,1,a.Vref-DAE.y(a.vref),DAE.m,1);
