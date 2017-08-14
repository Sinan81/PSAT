function xfirst(a)

if ~a.n, return, end

global DAE

DAE.x(a.slip) = ~a.z.*a.u; % slip = 1 at start-up

ord3 = find(a.con(:,5) == 3);
ord5 = find(a.con(:,5) == 5);

if ~isempty(ord3)
  u = a.z(ord3).*a.u(ord3);
  DAE.x(a.e1r(ord3)) = 0.05*u;
  DAE.x(a.e1m(ord3)) = 0.9*u;
end

if ~isempty(ord5)
  u = a.z(ord5).*a.u(ord5);
  DAE.x(a.e1r(ord5)) = 0.05*u;
  DAE.x(a.e1m(ord5)) = 0.9*u;
  DAE.x(a.e2r(ord5)) = 0.05*u;
  DAE.x(a.e2m(ord5)) = 0.9*u;
end
