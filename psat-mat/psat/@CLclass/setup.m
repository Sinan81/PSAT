function a = setup(a)

global Exc Svc Cac

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));

a.exc = find(a.con(:,3) == 1);
a.svc = find(a.con(:,3) == 2);
a.syn = Exc.syn(a.con(a.exc,2));

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end

% the cluster controller is inactive 
% if the Central Area Controller, 
% the AVR, or the SVC is off-line

a.u = a.u.*Cac.u(a.con(:,1));
a.u(a.exc) = a.u(a.exc).*Exc.u(a.con(a.exc,2));
a.u(a.svc) = a.u(a.svc).*Svc.u(a.con(a.svc,2));

a.store = a.con;
