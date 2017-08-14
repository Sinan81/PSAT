function a = setx0(a)

global DAE Syn

if ~a.n, return, end

check = 1;

% AVR types
type = a.con(:,2);
ty1 = find(type == 1);
ty2 = find(type == 2);
ty3 = find(type == 3);

% bus voltages, field voltages & common parameters
vg = DAE.y(a.vbus);
vf = a.u.*Syn.vf0(a.syn);
vrmax = a.u.*a.con(:,3);
vrmin = a.u.*a.con(:,4);
Te = a.con(:,10);
Tr = a.con(:,11);

% common warnings
idx = find(Te <= 0);
if idx
  Te(idx) = 1;
  a.con(idx,10) = 1;
  warn(a,idx,[' Te is negative or zero. ', ...
	       'Default value Te = 1 s will be used.'])
end
idx = find(Tr <= 0);
if idx
  Tr(idx) = 0.001;
  a.con(idx,11) = 0.001;
  warn(a,idx,[' Tr is negative or zero. ', ...
	       'Default value Tr = 0.001 s will be used.'])
end

if ty1
  A = a.con(ty1,12);
  B = a.con(ty1,13);
  %Ce = -vf(ty1).*(1+A.*(exp(B.*abs(vf(ty1)))-1));
  Ce = -vf(ty1) -  ceiling(a,vf(ty1),A,B,1);
  m0 = a.con(ty1,5);
  T1 = a.con(ty1,6);
  T2 = a.con(ty1,7);
  T3 = a.con(ty1,8);
  T4 = a.con(ty1,9);
  idx = find(m0 <= 0);
  if idx
    m0(idx) = 400;
    a.con(ty1(idx),5) = 400;
    warn(a,ty1(idx), [' m0 cannot be zero. ', ...
	    'Default value m0 = 400 will be used.'])
  end
  idx = find(T1 <= 0);
  if idx
    T1(idx) = 0.1;
    a.con(ty1(idx),6) = 0.1;
    warn(a,ty1(idx), [' T1 cannot be zero. ', ...
	    'Default value T1 = 0.1 will be used.'])
  end
  idx = find(T4 <= 0);
  if idx
    T4(idx) = 0.01;
    a.con(ty1(idx),9) = 0.01;
    warn(a,ty1(idx), [' T4 cannot be zero. ', ...
		  'Default value T4 = 0.01 will be used.'])
  end
  K1 = m0.*T2./T1;
  K2 = m0 - K1;
  K3 = T3./T4;
  K4 = 1 - K3;
  DAE.x(a.vm(ty1)) = a.u(ty1).*vg(ty1);
  a.vref0(ty1) = vg(ty1)-Ce./m0;

  DAE.x(a.vr1(ty1)) = a.u(ty1).*K2.*(a.vref0(ty1)-vg(ty1));
  DAE.x(a.vr2(ty1)) = a.u(ty1).*K4.*(a.vref0(ty1)-vg(ty1));
  DAE.x(a.vf(ty1)) = vf(ty1);
  
  vr = a.u(ty1).*(m0.*DAE.x(a.vr2(ty1))+K3.*(K1.*(a.vref0(ty1)-vg(ty1))+DAE.x(a.vr1(ty1))));
  idx = find(vr > vrmax(ty1));
  if idx
    check = 0;
    warn(a,ty1(idx),' Vr is over its max limit.')
  end
  idx = find(vr < vrmin(ty1));
  if idx
    check = 0;
    warn(a,ty1(idx),' Vr is under its min limit.')
  end
end

if ty2
  A = a.con(ty2,12);
  B = a.con(ty2,13);
  Ke = a.con(ty2,9);
  idx = find(Ke == 0);
  if idx
    a.con(ty2(idx),9) = 1;
    Ke(idx) = 1;
    warn(a,ty2(idx),[' Ke cannot be zero. ', ...
	    'Default value Ke = 1 will be used.'])
  end
  %Ce = vf(ty2).*(1+A.*(exp(B.*abs(vf(ty2)))-1));
  Ce = Ke.*vf(ty2) + ceiling(a,vf(ty2),A,B,1);
  Ka = a.con(ty2,5);
  Ta = a.con(ty2,6);
  Kf = a.con(ty2,7);
  Tf = a.con(ty2,8);
  idx = find(Tf <= 0);
  if idx
    Tf(idx) = 0.1;
    a.con(ty2(idx),8) = 0.1;
    warn(a,ty2(idx),[' Tf cannot be zero. ', ...
	    'Default value Tf = 0.1 will be used.'])
  end
  idx = find(Ta <= 0);
  if idx
    a.con(ty2(idx),6) = 0.1;
    warn(a,ty2(idx),[' Ta cannot be zero. ', ...
	    'Default value Ta = 0.1 will be used.'])
  end

  DAE.x(a.vm(ty2))  = a.u(ty2).*vg(ty2);
  DAE.x(a.vr1(ty2)) = Ce;
  DAE.x(a.vr2(ty2)) = -Kf.*vf(ty2)./Tf;
  DAE.x(a.vf(ty2)) = vf(ty2);
  
  a.vref0(ty2) = Ce./Ka+vg(ty2);
  
  idx = find(Ce > vrmax(ty2));
  if idx
    check = 0;
    warn(a,ty2(idx),' Vr1 is over its max limit.')
  end
  idx = find(Ce < vrmin(ty2));
  if idx
    check = 0;
    warn(a,ty2(idx),' Vr1 is under its min limit.')
  end
end

if ty3
  T2 = a.con(ty3,6);
  a.con(ty3,8) = Syn.vf0(a.syn(ty3)); % offset vf0
  
  % signal V/V0 & initial voltage v0
  z = a.con(ty3,9);
  idx = find(z);
  if ~isempty(idx), a.con(ty3(idx),9) = vg(ty3(idx)); end

  a.vref0(ty3) = vg(ty3);
  
  DAE.x(a.vm(ty3))  = a.u(ty3).*vg(ty3);
  DAE.x(a.vr3(ty3)) = 0;
  DAE.x(a.vf(ty3)) = vf(ty3);

  idx = find(T2 <= 0);
  if idx
    a.con(ty3(idx),6) = 0.1;
    warn(a,ty3(idx),[' T2 cannot be zero. ', ...
	    'Default value T2 = 0.1 will be used.'])
  end
  idx = find(vf((ty3)) > vrmax(ty3));
  if idx
    check = 0;
    warn(a,ty3(idx),' Vf is over its max limit.')
  end
  idx = find(vf(ty3) < vrmin(ty3));
  if idx
    check = 0;
    warn(a,ty3(idx),' Vf is under its min limit.')
  end
end

% set algebraic variables
DAE.y(a.vref) = a.u.*a.vref0;

% reset synchronous machine field voltages
Syn.vf0(a.syn(find(a.u))) = 0;

if ~check
  fm_disp('Automatic Voltage Regulators cannot be properly initialized.')
else
  fm_disp('Initialization of Automatic Voltage Regulators completed.')
end
