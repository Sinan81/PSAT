function a = setup(a)
% initializes the main devices properties using the property con
global Syn 

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
a.syn = a.con(:,1);
a.bus = getbus(Syn,a.syn);

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end
% the TG is inactive if the machine is off-line
a.u = a.u.*Syn.u(a.syn);

a.store = a.con;
