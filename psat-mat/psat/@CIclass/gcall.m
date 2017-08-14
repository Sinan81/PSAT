function gcall(a)

global DAE

if ~a.n, return, end

delta = zeros(a.n,1);
omega = ones(a.n,1);

for i = 1:a.n
  idx = a.syn{i};
  delta(i) = sum(a.M(idx).*DAE.x(a.dgen(idx)))/a.Mtot(i);
  omega(i) = sum(a.M(idx).*DAE.x(a.wgen(idx)))/a.Mtot(i);
end

DAE.g = DAE.g ...
    + sparse(a.delta,1,delta-DAE.y(a.delta),DAE.m,1) ...
    + sparse(a.omega,1,omega-DAE.y(a.omega),DAE.m,1);

