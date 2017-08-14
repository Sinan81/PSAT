function gcall(p)

global DAE Settings

if ~p.n, return, end

DAE.g(p.bus) = p.u.*p.con(:,4) + DAE.g(p.bus);
DAE.g(p.vbus) = p.u.*p.con(:,5) + DAE.g(p.vbus);
if Settings.forcepq, return, end
a = find((DAE.y(p.vbus) < p.con(:,7) & p.con(:,8) & p.u) | p.shunt);
b = find(DAE.y(p.vbus) > p.con(:,6) & p.con(:,8) & p.u);
if ~isempty(a)
  k = p.bus(a);
  h = p.vbus(a);
  DAE.g(k) = p.con(a,4).*DAE.y(h).*DAE.y(h)./p.con(a,7)./p.con(a,7) ...
      + DAE.g(k) - p.con(a,4);
  DAE.g(h) = p.con(a,5).*DAE.y(h).*DAE.y(h)./p.con(a,7)./p.con(a,7) ...
      + DAE.g(h) - p.con(a,5);
end
if ~isempty(b)
  k = p.bus(b);
  h = p.vbus(b);
  DAE.g(k) = p.con(b,4).*DAE.y(h).*DAE.y(h)./p.con(b,6)./p.con(b,6) + ...
      DAE.g(k) - p.con(b,4);
  DAE.g(h) = p.con(b,5).*DAE.y(h).*DAE.y(h)./p.con(b,6)./p.con(b,6) + ...
      DAE.g(h) - p.con(b,5);
end
