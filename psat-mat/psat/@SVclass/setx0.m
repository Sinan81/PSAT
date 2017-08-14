function a = setx0(a)

global Bus DAE PV Syn

if ~a.n, return, end

V = DAE.y(a.vbus);

% eliminate PV components used for initializing SVC's
for i = 1:a.n
  idxg = findbus(Syn, a.bus(i));
  if ~isempty(idxg)
    warn(a, i, [' SVC cannot be connected at the same bus as ' ...
                'synchronous machines.'])
    continue
  end
  idx = findbus(PV, a.bus(i));
  PV = remove(PV, idx);
  if isempty(idx)
    warn(a, i, ' no PV generator found at the SVC bus.')
  end
end

if a.ty1
  Kr = a.con(a.ty1,7);
  bcv_max = a.u(a.ty1).*a.con(a.ty1,9);
  bcv_min = a.u(a.ty1).*a.con(a.ty1,10);
  DAE.x(a.bcv) = a.u(a.ty1).*Bus.Qg(a.bus(a.ty1))./V(a.ty1)./V(a.ty1);
  a.con(a.ty1,8) = DAE.x(a.bcv)./Kr + V(a.ty1);
  idx = find(DAE.x(a.bcv) > bcv_max);
  if idx, warn(a, a.ty1(idx), ' b_svc is over its max limit.'), end
  idx = find(DAE.x(a.bcv) < bcv_min);
  if idx, warn(a, a.ty1(idx), ' b_svc is under its min limit.'), end
  DAE.x(a.bcv) = max(DAE.x(a.bcv),bcv_min);
  DAE.x(a.bcv) = min(DAE.x(a.bcv),bcv_max);
  a.Be(a.ty1) = DAE.x(a.bcv);
end

if a.ty2
  a_max = a.u(a.ty2).*a.con(a.ty2,9);
  a_min = a.u(a.ty2).*a.con(a.ty2,10);
  T2 = a.con(a.ty2,6);
  K = a.con(a.ty2,7);
  Kd = a.con(a.ty2,11);
  T1 = a.con(a.ty2,12);
  Km = a.con(a.ty2,13);
  Tm = a.con(a.ty2,14);
  xl = a.con(a.ty2,15);
  xc = a.con(a.ty2,16);
  DAE.x(a.vm) = a.u(a.ty2).*V(a.ty2)./Km;
  b = pi*(2-xl./xc)+pi*xl.*Bus.Qg(a.bus(a.ty2))./V(a.ty2)./V(a.ty2);
  % numeric solution for alpha
  for i = 1:length(a.ty2)
    err = a.u(a.ty2(i));
    % first guess is the expansion of a 3rd order Taylor series
    s = a.u(a.ty2(i))*sign(b(i))*((6*abs(b(i)))^(1/3))/2;
    iter = 0;
    while abs(err) > 1e-8
      if iter > 20,
        warn(a, a.ty2(i),' convergence not reached while computing alpha.')
        break,
      end
      ga = 2*s - sin(2*s) - b(i);
      ja = 2*(1-cos(2*s));
      err = -ga/ja;
      s = s + err;
      iter = iter + 1;
    end
    DAE.x(a.alpha(i)) = s;
  end
  a.con(a.ty2,8) = DAE.x(a.vm) + Kd./K.*DAE.x(a.alpha);
  idx = find(DAE.x(a.alpha) > a_max);
  if idx, warn(a, a.ty2(idx), ' alpha is over its max limit.'), end
  idx = find(DAE.x(a.alpha) < a_min);
  if idx, warn(a, a.ty2(idx), ' alpha is under its min limit.'), end
  DAE.x(a.alpha) = max(DAE.x(a.alpha),a_min);
  DAE.x(a.alpha) = min(DAE.x(a.alpha),a_max);
  a.Be(a.ty2) = a.u(a.ty2).*(2*DAE.x(a.alpha) - sin(2*DAE.x(a.alpha)) - ...
                             pi*(2-xl./xc))./(pi*xl);
end

% reference voltages
DAE.y(a.vref) = a.con(:,8);
DAE.y(a.q) = a.u.*bsvc(a).*V.*V;

fm_disp('Initialization of SVCs completed.')
