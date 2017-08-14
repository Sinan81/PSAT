function Glcall(a)

if ~a.n, return, end

global DAE

V = DAE.y(a.vbus);

DAE.Gl = DAE.Gl + ...
        sparse(a.bus, 1, a.u.*((a.con(:,5).*V+a.con(:,6)).*V+a.con(:,7)),DAE.m,1) + ...
        sparse(a.vbus,1, a.u.*((a.con(:,8).*V+a.con(:,9)).*V+a.con(:,10)),DAE.m,1);
