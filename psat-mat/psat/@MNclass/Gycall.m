function Gycall(a,lambda)

if ~a.n, return, end

global DAE Settings

V = DAE.y(a.vbus);

if Settings.init
  DAE.Gy = DAE.Gy + sparse(a.bus,a.vbus,DAE.lambda*a.u.*a.con(:,4).* ...
                             a.con(:,6).*V.^(a.con(:,6)-1),DAE.m,DAE.m);
  DAE.Gy = DAE.Gy + sparse(a.vbus,a.vbus,DAE.lambda*a.u.*a.con(:,5).* ...
                             a.con(:,7).*V.^(a.con(:,7)-1),DAE.m,DAE.m);
elseif a.init
  i = a.init;
  DAE.Gy = DAE.Gy + sparse(a.bus(i),a.vbus(i),DAE.lambda*a.u(i).*a.con(i,4).* ...
                             a.con(i,6).*V(i).^(a.con(i,6)-1),DAE.m,DAE.m);
  DAE.Gy = DAE.Gy + sparse(a.vbus(i),a.vbus(i),DAE.lambda*a.u(i).*a.con(i,5).* ...
                             a.con(i,7).*V(i).^(a.con(i,7)-1),DAE.m,DAE.m);
end
