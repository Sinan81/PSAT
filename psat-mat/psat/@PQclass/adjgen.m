function adjgen(a)

global Bus DAE

if ~a.n, return, end

idx = find(a.gen);

if isempty(idx), return, end

p = a.P0(idx);
q = a.Q0(idx);

yp = find((DAE.y(a.vbus(idx)) < a.con(idx,7) & a.con(idx,8) & a.u(idx)) | a.shunt(idx));
yq = find(DAE.y(a.vbus(idx)) > a.con(idx,6) & a.con(idx,8) & a.u(idx));

if ~isempty(yp)
  k = idx(yp);
  h = a.vbus(k);
  v = DAE.y(h).*DAE.y(h);
  p(yp) = p(yp).*v./a.con(k,7)./a.con(k,7);
  q(yp) = q(yp).*v./a.con(k,7)./a.con(k,7);
end

if ~isempty(yq)
  k = idx(yq);
  h = a.vbus(yq);
  v = DAE.y(h).*DAE.y(h);
  p(yq) =  p(yq).*v./a.con(k,6)./a.con(k,6);
  q(yq) =  q(yq).*v./a.con(k,6)./a.con(k,6);
end

Bus.Pg(a.bus(idx)) = Bus.Pg(a.bus(idx)) - p;
Bus.Qg(a.bus(idx)) = Bus.Qg(a.bus(idx)) - q;
Bus.Pl(a.bus(idx)) = Bus.Pl(a.bus(idx)) - p;
Bus.Ql(a.bus(idx)) = Bus.Ql(a.bus(idx)) - q;
