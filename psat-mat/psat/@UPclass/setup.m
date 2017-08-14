function a = setup(a)

global Line Bus

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
a.line = a.con(:,1);
a.Cp = a.con(:,6)./100;

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end

[Line,a.bus1,a.bus2,a.xcs,a.y] = factsetup(Line,a.line,a.u.*a.Cp,'UPFC');

a.v1 = a.bus1 + Bus.n;
a.v2 = a.bus2 + Bus.n;

a.store = a.con;
