function H = hessian(a,ro)
% compute the Hessian matrix of Shunt equations

global DAE

H = sparse(DAE.m,DAE.m);

if ~a.n, return, end

H = sparse(a.vbus,a.vbus, ...
           2*a.u.*a.con(:,5).*ro(a.bus) - ...
           2*a.u.*a.con(:,6).*ro(a.vbus), ...
           DAE.m,DAE.m);

