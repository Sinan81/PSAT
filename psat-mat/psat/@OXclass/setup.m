function a = setup(a)

global Bus Exc Syn

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
a.exc = a.con(:,1);
a.syn = Exc.syn(a.exc);
a.bus = getbus(Syn,a.syn);
a.vbus = a.bus + Bus.n;

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end
% the OXL is inactive if the AVR is off-line
a.u = a.u.*Exc.u(a.exc);

a.store = a.con;
