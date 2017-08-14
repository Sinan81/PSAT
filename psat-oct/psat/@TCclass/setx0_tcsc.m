function a = setx0_tcsc(a)

global Line DAE Settings

if ~a.n, return, end

% reset transmission line reactance and admittance matrix
Line = mulxl_line(Line,a.line,1./(1-a.u.*a.Cp));
if sum(a.u), Line = build_y_line(Line); end

x0 = zeros(a.n,1);
if a.ty1
  x0(a.ty1) = a.u(a.ty1).*a.Cp(a.ty1).*getxl_line(Line,a.line(a.ty1));
end

if a.ty2
  af = -pi/2:0.025:pi/2;
  for i = 1:length(a.ty2)
    % find a "good" initial guess in a brutal way...
    B = balpha_tcsc(a,af,a.ty2(i),1);
    B0 = a.B(a.ty2(i));
    [val,idx] = min(abs(B-B0));
    B1 = B(idx);
    af0 = af(idx);
    err = a.u(a.ty2(i));
    iter = 0;
    while abs(B1-B0) > Settings.lftol
      if iter > 20, break, end
      B1 = balpha_tcsc(a,af0,a.ty2(i),1);
      dB = balpha_tcsc(a,af0,a.ty2(i),2);
      err = -(B1-B0)/dB;
      af0 = af0 + err;
      iter = iter + 1;
    end
    if iter > 20
      warn_tcsc(a,a.ty2(i),[': initialization of alpha failed.'])
    end
    x0(a.ty2(i)) = a.u(a.ty2(i))*af0; 
  end
end

jdx = find(x0 > a.con(:,10));
if jdx
  warn_tcsc(a,jdx,': state variable is over its maximum limit.')
end
jdx = find(x0 < a.con(:,11));
if jdx
  warn_tcsc(a,jdx,': state variable is under its minimum limit.')
end

x0 = min(x0,a.u.*a.con(:,10));
x0 = max(x0,a.u.*a.con(:,11));

ty2 = a.con(:,3) == 2;
tya = a.con(:,4) == 2;

% initial state variables and reference
a.X0 = x0;
DAE.x(a.x1) = x0;
if ty2, DAE.x(a.x2(ty2)) = x0(ty2); end
% if ty2, DAE.x(a.x2(ty2)) = -x0(ty2); end

% reference power
[Ps,Qs,Pr,Qr] = flows_line(Line,'pq',a.line);
[Ps,Qs,Pr,Qr] = flows_tcsc(a,Ps,Qs,Pr,Qr,'tcsc');
a.Pref = (Ps + ty2.*tya.*Pr);

DAE.y(a.x0) = a.X0;
DAE.y(a.pref) = a.Pref;

fm_disp('Initialization of TCSC completed.')
