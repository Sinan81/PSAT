function a = setx0(a)

global DAE Bus Settings jay

if ~a.n, return, end

% machine dynamic orders
ord = a.con(:,5);

% indexes of machine orders
is2 = find(ord == 2);
is3 = find(ord == 3);
is4 = find(ord == 4);
is51 = find(ord == 5.1);
is52 = find(ord == 5.2);
is53 = find(ord == 5.3);
is6 = find(ord == 6);
is8 = find(ord == 8);

% indexes of machine buses
bs2 = a.bus(is2);
bs3 = a.bus(is3);
bs4 = a.bus(is4);
bs51 = a.bus(is51);
bs52 = a.bus(is52);
bs53 = a.bus(is53);
bs6 = a.bus(is6);
bs8 = a.bus(is8);

% constants
a.c1 = zeros(a.n,1);
a.c2 = zeros(a.n,1);
a.c3 = zeros(a.n,1);

% check parameters
% -------------------------------------------------------------------
% check inertia M and x'd
idx = find(a.con(:,18) <= 0);
if ~isempty(idx)
  a.con(idx,18) = 10;
  if Settings.conv
    a.con(idx,18) = a.con(idx,18).*a.con(idx,2)/Settings.mva;
  end
  warn(a,idx,' Inertia cannot be <= 0. M = 10 [kWs/kVa] will be used.')
end
idx = find(a.con(:,9) <= 0);
if ~isempty(idx)
  a.con(idx,9) = 0.302;
  if Settings.conv
    a.con(idx,9)= (a.con(idx,9)./a.con(idx,2))*Settings.mva;
  end
  warn(a,idx,' x''d cannot be <= 0. x''d = 0.302 [p.u.] will be used.')
end
% check xd, T'd0 and T"d0
is = [is3; is4; is51; is52; is53; is6; is8];
idx = find(a.con(is,8) <= 0);
if ~isempty(idx)
  idx = is(idx);
  a.con(idx,8) = 1.90;
  if Settings.conv
    a.con(idx,8)= (a.con(idx,8)./a.con(idx,2))*Settings.mva;
  end
  warn(a,idx,' xd cannot be <= 0. xd = 1.90 [p.u.] will be used.')
end
idx = find(a.con(is,11) <= 0);
if ~isempty(idx)
  idx = is(idx);
  a.con(idx,11) = 8.00;
  warn(a,idx,' T''d0 cannot be <= 0. T''d0 = 8.00 [s] will be used.')
end
% check T"d0, x"d and x"q
is = [is52; is6; is8];
idx = find(a.con(is,12) <= 0);
if ~isempty(idx)
  idx = is(idx);
  a.con(idx,12) = 0.04;
  warn(a,idx,' T"d0 cannot be <= 0. T"d0 = 0.04 [s] will be used.')
end
idx = find(a.con(is,10) <= 0);
if ~isempty(idx)
  idx = is(idx);
  a.con(idx,10) = 0.204;
  if Settings.conv
    a.con(idx,10)= (a.con(idx,10)./a.con(idx,2))*Settings.mva;
  end
  warn(a,idx,' x"d cannot be <= 0. x"d = 0.204 [p.u.] will be used.')
end
idx = find(a.con(is,15) <= 0);
if ~isempty(idx)
  idx = is(idx);
  a.con(idx,15) = 0.30;
  if Settings.conv
    a.con(idx,15)= (a.con(idx,15)./a.con(idx,2))*Settings.mva;
  end
  warn(a,idx,' x"q cannot be <= 0. x"q = 0.30 [p.u.] will be used.')
end
% check T'q0
is = [is4; is51; is6; is8];
idx = find(a.con(is,16) <= 0);
if ~isempty(idx)
  idx = is(idx);
  a.con(idx,16) = 0.80;
  warn(a,idx,' T''q0 cannot be <= 0. T''q0 = 0.80 [s] will be used.')
end
% check T"q0
is = [is51; is52; is6; is8];
idx = find(a.con(is,17) <= 0);
if ~isempty(idx)
  idx = is(idx);
  a.con(idx,17) = 0.02;
  warn(a,idx,' T"q0 cannot be <= 0. T"q0 = 0.02 [s] will be used.')
end
% check xq
is = [is3; is4; is51; is52; is53; is6; is8];
idx = find(a.con(is,13) <= 0);
if ~isempty(idx)
  idx = is(idx);
  a.con(idx,13) = 1.70;
  if Settings.conv
    a.con(idx,13)= (a.con(idx,13)./a.con(idx,2))*Settings.mva;
  end
  warn(a,idx,' xq cannot be <= 0. xq = 1.70 [p.u.] will be used.')
end
% check x'q
is = [is4; is51; is6; is8];
idx = find(a.con(is,14) <= 0);
if ~isempty(idx)
  idx = is(idx);
  a.con(idx,14) = 0.50;
  if Settings.conv
    a.con(idx,14)= (a.con(idx,14)./a.con(idx,2))*Settings.mva;
  end
  warn(a,idx,' x''q cannot be <= 0. x''q = 0.50 [p.u.] will be used.')
end
% check Taa and saturation factors
% if saturation factors are defined, Taa = 0 is used.
idx = find(a.con(:,25) | a.con(:,26));
if ~isempty(idx)
  a.con(idx,24) = 0;
end

% parameters
ra = a.con(:,7);
xd = a.con(:,8);
xd1 = a.con(:,9);
xd2 = a.con(:,10);
xq = a.con(:,13);
xq1 = a.con(:,14);
xq2 = a.con(:,15);
Td10 = a.con(:,11);
Tq10 = a.con(:,16);
Td20 = a.con(:,12);
Tq20 = a.con(:,17);
Kp = a.con(:,21);
Taa = a.con(:,24);

% adjusting parameters for initialization
if ~isempty(is2)
  xq(is2) = xd1(is2);
end

% rotor speeds
DAE.x(a.omega) = a.u;

% check active and reactive power ratios
synbus = sort(a.bus);
n_old = -1;
for i = 1:a.n
  n_new = synbus(i);
  if n_new ~= n_old
    idx = find(a.bus == n_new);
    if length(idx) == 1
      if a.con(idx,22) ~= 1
        fm_disp(['Warning: Active power ratio of ', ...
                 'generator #', ...
                 num2str(idx),' must be 1'])
        a.con(idx,22) = 1;
      end
      if a.con(idx,23) ~= 1
        fm_disp(['Warning: Reactive power ratio of ', ...
                 'generator #', ...
                 num2str(idx),' must be 1'])
        a.con(idx,23) = 1;
      end
    elseif length(idx) > 1
      numsyn = length(idx);
      ratiop = sum(a.con(idx,22));
      ratioq = sum(a.con(idx,23));
      if abs(ratiop-1) > 1e-5
        fm_disp(['Warning: The sum of active power ', ...
                 'ratios of generators #', ...
                 num2str(idx'),' must be 1'])
        a.con(idx,22) = 1/numsyn;
      else
        a.con(idx(1),22) = a.con(idx(1),22)-(ratiop-1);
      end
      if abs(ratioq-1) > 1e-5
        fm_disp(['Warning: The sum of reactive power ', ...
                 'ratios of generators #', ...
                 num2str(idx'),' must be 1'])
        a.con(idx,23) = 1/numsyn;
      else
        a.con(idx(1),23) = a.con(idx(1),23)-(ratioq-1);
      end
    end
    n_old = n_new;
  end
end

% powers and rotor angles
DAE.y(a.p) = a.u.*Bus.Pg(a.bus).*a.con(:,22);
DAE.y(a.q) = a.u.*Bus.Qg(a.bus).*a.con(:,23);
a.Pg0 = DAE.y(a.p);
Vg = DAE.y(a.vbus);
ag = DAE.y(a.bus);
V =  Vg.*exp(jay*ag);
S = DAE.y(a.p) - jay*DAE.y(a.q);
I = S./conj(V);
delta = angle(V + (ra + jay*xq).*I);
DAE.x(a.delta) = a.u.*delta;

% d and q-axis voltages and currents
Vdq = a.u.*V.*exp(-jay*(delta-pi/2));
Idq = a.u.*I.*exp(-jay*(delta-pi/2));
vd = real(Vdq);
vq = imag(Vdq);
a.Id = real(Idq);
a.Iq = imag(Idq);

% mechanical torques/powers
a.pm0 = (vq+ra.*a.Iq).*a.Iq+(vd+ra.*a.Id).*a.Id;

% remaining state variables and field voltages
if ~isempty(is2)
  K = 1./(ra(is2).^2+xd1(is2).^2);
  a.c1(is2) = ra(is2).*K;
  a.c2(is2) = xd1(is2).*K;
  a.c3(is2) = xd1(is2).*K;
  a.vf0(is2) = vq(is2)+ra(is2).*a.Iq(is2)+xd1(is2).*a.Id(is2);
end
if ~isempty(is3)
  K = 1./(ra(is3).^2+xq(is3).*xd1(is3));
  a.c1(is3) = ra(is3).*K;
  a.c2(is3) = xd1(is3).*K;
  a.c3(is3) = xq(is3).*K;
  DAE.x(a.e1q(is3)) = vq(is3)+ra(is3).*a.Iq(is3)+xd1(is3).*a.Id(is3);
  a.vf0(is3) = synsat(a,1,DAE.x(a.e1q(is3)),is3)+(xd(is3)-xd1(is3)).*a.Id(is3);
end
if ~isempty(is4)
  K = 1./(ra(is4).^2+xq1(is4).*xd1(is4));
  a.c1(is4) = ra(is4).*K;
  a.c2(is4) = xd1(is4).*K;
  a.c3(is4) = xq1(is4).*K;
  DAE.x(a.e1q(is4)) = vq(is4)+ra(is4).*a.Iq(is4)+xd1(is4).*a.Id(is4);
  DAE.x(a.e1d(is4)) = vd(is4)+ra(is4).*a.Id(is4)-xq1(is4).*a.Iq(is4);
  a.vf0(is4) = synsat(a,1,DAE.x(a.e1q(is4)),is4)+ ...
      (xd(is4)-xd1(is4)).*a.Id(is4);
end
if ~isempty(is51)
  K = 1./(ra(is51).^2+xd1(is51).^2);
  a.c1(is51) = ra(is51).*K;
  a.c2(is51) = xd1(is51).*K;
  a.c3(is51) = xd1(is51).*K;
  DAE.x(a.e1q(is51)) = vq(is51)+ra(is51).*a.Iq(is51)+xd1(is51).*a.Id(is51);
  DAE.x(a.e2d(is51)) = vd(is51)+ra(is51).*a.Id(is51)-xd1(is51).*a.Iq(is51);
  DAE.x(a.e1d(is51)) = (xq(is51)-xq1(is51)- ...
                          Tq20(is51).*xd1(is51).* ...
                          (xq(is51)-xq1(is51))./Tq10(is51)./ ...
                          xq1(is51)).*a.Iq(is51);
  a.vf0(is51) = synsat(a,1,DAE.x(a.e1q(is51)),is51)+ ...
      (xd(is51)-xd1(is51)).*a.Id(is51);
end
if ~isempty(is52)
  K = 1./(ra(is52).^2+xq2(is52).*xd2(is52));
  a.c1(is52) = ra(is52).*K;
  a.c2(is52) = xd2(is52).*K;
  a.c3(is52) = xq2(is52).*K;
  DAE.x(a.e2q(is52)) = vq(is52)+ra(is52).*a.Iq(is52)+xd2(is52).*a.Id(is52);
  DAE.x(a.e2d(is52)) = vd(is52)+ra(is52).*a.Id(is52)-xq2(is52).*a.Iq(is52);
  k1 = xd(is52)-xd1(is52)-Td20(is52).*xd2(is52).* ...
       (xd(is52)-xd1(is52))./Td10(is52)./xd1(is52);
  k2 = xd1(is52)-xd2(is52)+Td20(is52).*xd2(is52).* ...
       (xd(is52)-xd1(is52))./Td10(is52)./xd1(is52);
  %a.vf0(is52) = (k1+k2).*a.Id(is52)+DAE.x(a.e2q(is52));
  DAE.x(a.e1q(is52)) = -k1.*Taa(is52)./Td10(is52).* ...
      a.Id(is52)+(1-Taa(is52)./Td10(is52)).* ...
      (DAE.x(a.e2q(is52)) + k2.*a.Id(is52));
  a.vf0(is52) = (k1.*a.Id(is52)+synsat(a,1,DAE.x(a.e1q(is52)),is52))./ ...
      (1-Taa(is52)./Td10(is52));
end
if ~isempty(is53)
  DAE.x(a.psid(is53)) = ra(is53).*a.Iq(is53) + vq(is53);
  DAE.x(a.psiq(is53)) = -(ra(is53).*a.Id(is53) + vd(is53));
  DAE.x(a.e1q(is53)) = DAE.x(a.psid(is53)) + xd(is53).*a.Id(is53);
  a.vf0(is53) = DAE.x(a.e1q(is53));
end
if ~isempty(is6)
  K = 1./(ra(is6).^2+xq2(is6).*xd2(is6));
  a.c1(is6) = ra(is6).*K;
  a.c2(is6) = xd2(is6).*K;
  a.c3(is6) = xq2(is6).*K;
  DAE.x(a.e2q(is6)) = vq(is6)+ra(is6).*a.Iq(is6)+xd2(is6).*a.Id(is6);
  DAE.x(a.e2d(is6)) = vd(is6)+ra(is6).*a.Id(is6)-xq2(is6).*a.Iq(is6);
  DAE.x(a.e1d(is6)) = (xq(is6)-xq1(is6)-Tq20(is6).* ...
                       xq2(is6).*(xq(is6)-xq1(is6))./ ...
                       Tq10(is6)./xq1(is6)).*a.Iq(is6);
  k1 = xd(is6)-xd1(is6)-Td20(is6).*xd2(is6).* ...
       (xd(is6)-xd1(is6))./Td10(is6)./xd1(is6);
  k2 = xd1(is6)-xd2(is6)+Td20(is6).*xd2(is6).* ...
       (xd(is6)-xd1(is6))./Td10(is6)./xd1(is6);
  %a.vf0(is6) = (k1+k2).*a.Id(is6)+DAE.x(a.e2q(is6));
  DAE.x(a.e1q(is6)) = DAE.x(a.e2q(is6))+k2.*a.Id(is6)- ...
      Taa(is6)./Td10(is6).*((k1+k2).*a.Id(is6)+DAE.x(a.e2q(is6)));
  a.vf0(is6) = (k1.*a.Id(is6)+synsat(a,1,DAE.x(a.e1q(is6)),is6))./ ...
      (1-Taa(is6)./Td10(is6));
end
if ~isempty(is8)
  DAE.x(a.psid(is8)) =  ra(is8).*a.Iq(is8) + vq(is8);
  DAE.x(a.psiq(is8)) = -ra(is8).*a.Id(is8) - vd(is8);

  DAE.x(a.e2d(is8)) = -DAE.x(a.psiq(is8)) - xq2(is8).*a.Iq(is8);
  DAE.x(a.e2q(is8)) =  DAE.x(a.psid(is8)) + xd2(is8).*a.Id(is8);
  
  DAE.x(a.e1d(is8)) = (xq(is8)-xq1(is8)-Tq20(is8).* ...
                       xq2(is8).*(xq(is8)-xq1(is8))./ ...
                       Tq10(is8)./xq1(is8)).*a.Iq(is8);
  
  k1 = xd(is8)-xd1(is8)-Td20(is8).*xd2(is8).* ...
       (xd(is8)-xd1(is8))./Td10(is8)./xd1(is8);
  
  k2 = xd1(is8)-xd2(is8)+Td20(is8).*xd2(is8).* ...
       (xd(is8)-xd1(is8))./Td10(is8)./xd1(is8);
  
  %a.vf0(is8) = (k1+k2).*a.Id(is8)+DAE.x(a.e2q(is8));
  
  DAE.x(a.e1q(is8)) = -k1.*Taa(is8)./Td10(is8).* ...
      a.Id(is8)+(1-Taa(is8)./Td10(is8)).* ...
      (DAE.x(a.e2q(is8)) + k2.*a.Id(is8));
  
  a.vf0(is8) = (k1.*a.Id(is8)+synsat(a,1,DAE.x(a.e1q(is8)),is8))./ ...
      (1-Taa(is8)./Td10(is8));

end

DAE.y(a.pm) = a.u.*a.pm0;
DAE.y(a.vf) = a.u.*a.vf0;

% find & delete static generators
for j = 1:a.n
  if ~fm_rmgen(a.bus(j)*a.u(i)), check = 0; end
end

fm_disp('Initialization of Synchronous Machines completed.')

