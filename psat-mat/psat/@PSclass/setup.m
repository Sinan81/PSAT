function a = setup(a)

global Bus Syn Exc

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
a.exc = a.con(:,1);
a.syn = Exc.syn(a.exc);
a.bus = getbus(Syn,a.syn);
a.vbus= a.bus + Bus.n;
a.store = a.con;

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end

% the PSS is inactive if the AVR is off-line
a.u = a.u.*Exc.u(a.exc);

a.store = a.con;
