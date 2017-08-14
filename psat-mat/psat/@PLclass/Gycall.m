function Gycall(a)

if ~a.n, return, end

global DAE Settings

V = DAE.y(a.vbus);

if Settings.init
  DAE.Gy = DAE.Gy + sparse(a.bus,a.vbus,DAE.lambda*a.u.*(2*a.con(:,5).*V + ...
                             a.con(:,6)),DAE.m,DAE.m);
  DAE.Gy = DAE.Gy + sparse(a.vbus,a.vbus,DAE.lambda*a.u.*(2*a.con(:,8).*V + ...
                             a.con(:,9)),DAE.m,DAE.m);
elseif ~isempty(a.init)
  i = a.init;
  DAE.Gy = DAE.Gy + sparse( ...
      a.bus(i),a.vbus(i), ...
      DAE.lambda*a.u(i).*(2*a.con(i,5).*V(i)+a.con(i,6)),DAE.m,DAE.m);
  DAE.Gy = DAE.Gy + sparse( ...
      a.vbus(i),a.vbus(i), ...
      DAE.lambda*a.u(i).*(2*a.con(i,8).*V(i)+a.con(i,9)),DAE.m,DAE.m);
end
