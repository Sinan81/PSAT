function a = setx0(a)
% computes the initial value of state variables of the device after power
% flow analysis
global Syn DAE Settings

if ~a.n, return, end

Porder = Syn.pm0(a.syn);

if a.ty1
  
  Porder1 = Porder(a.ty1);
  gain = 1./a.con(a.ty1,4);
  tmax = a.con(a.ty1,5);
  tmin = a.con(a.ty1,6);
  Ts = a.con(a.ty1,7);
  Tc = a.con(a.ty1,8);
  T3 = a.con(a.ty1,9);
  T4 = a.con(a.ty1,10);
  T5 = a.con(a.ty1,11);
  
  as = 1./Ts;
  ac = 1./Tc;
  a5 = 1./T5;
  K1 = T3.*ac;
  K2 = 1 - K1;
  K3 = T4.*a5;
  K4 = 1 - K3;

  a.dat1 = [a.tg1(a.ty1), ...             %  1
            a.tg2(a.ty1), ...             %  2
            a.tg3(a.ty1), ...             %  3
            gain, ...                     %  4
            tmax, ...                     %  5
            Porder1, ...                  %  6
            as, ...                       %  7
            ac, ...                       %  8
            a5, ...                       %  9
            K1, ...                       % 10
            K2, ...                       % 11
            K3, ...                       % 12
            K4, ...                       % 13
            Syn.omega(a.syn(a.ty1)), ...  % 14
            zeros(length(a.ty1),1)];      % 15
  
  DAE.x(a.dat1(:,1)) = a.u(a.ty1).*a.dat1(:,6);
  DAE.x(a.dat1(:,2)) = a.u(a.ty1).*a.dat1(:,11).*a.dat1(:,6);
  DAE.x(a.dat1(:,3)) = a.u(a.ty1).*a.dat1(:,13).*a.dat1(:,6);
  DAE.f(a.dat1(:,1)) = 0;
  DAE.f(a.dat1(:,2)) = 0;
  DAE.f(a.dat1(:,3)) = 0;
  
end
%%
if a.ty2

  Porder2 = Porder(a.ty2);
  gain = 1./a.con(a.ty2,4);
  tmax = a.con(a.ty2,5);
  tmin = a.con(a.ty2,6);
  T1 = a.con(a.ty2,8);
  T2 = a.con(a.ty2,7);
  a2 = 1./T2;
  K1 = gain.*T1.*a2;
  K2 = gain - K1;
  
  a.dat2 = [a.tg(a.ty2), ...              %  1
            gain, ...                     %  2
            tmax, ...                     %  3
            tmin, ...                     %  4
            Porder2, ...                  %  5
            a2, ...                       %  6
            K1, ...                       %  7
            K2, ...                       %  8
            Syn.omega(a.syn(a.ty2))];     %  9
  
  DAE.x(a.dat2(:,1)) = 0;
  DAE.f(a.dat2(:,1)) = 0;
end
%%
if a.ty3

  Porder3 = Porder(a.ty3);
  Tg = a.con(a.ty3,4);  
  Gmax = a.con(a.ty3,5);
  Gmin = a.con(a.ty3,6);
  vmax = a.con(a.ty3,7);
  vmin = a.con(a.ty3,8);
  Tp = a.con(a.ty3,9);
  Tr = a.con(a.ty3,10);
  sigma = a.con(a.ty3,11);
  delta = a.con(a.ty3,12);
  Tw = a.con(a.ty3,13);
  a11 = a.con(a.ty3,14);
  a13 = a.con(a.ty3,15);
  a21 = a.con(a.ty3,16);
  a23 = a.con(a.ty3,17);
   
  ap = 1./Tp;
  ag = 1./Tg;
  ar = 1./Tr;
  aw = 1./Tw;
  K1 = 1./a11;
  K2 = aw.*K1;
  K3 = a13.*a21./a11;
  K4 = a11.*a23-a13.*a21;
  K5 = ap.*ag;
 
  a.dat3 = [a.tg1(a.ty3), ...             %  1
            a.tg2(a.ty3), ...             %  2
            a.tg3(a.ty3), ...             %  3
            a.tg4(a.ty3), ...             %  4
            K5, ...                       %  5
            Porder3, ...                  %  6
            ap, ...                       %  7
            ar, ...                       %  8
            aw, ...                       %  9
            K1, ...                       % 10
            K2, ...                       % 11
            K3, ...                       % 12
            K4, ...                       % 13
            sigma, ...                    % 14
            delta,...                     % 15
            a23,...                       % 16
            Syn.omega(a.syn(a.ty3)), ...  % 17
            zeros(length(a.ty3),1), ...   % 18
            zeros(length(a.ty3),1)];      % 19
            
  DAE.x(a.dat3(:,1)) = 0;
  DAE.x(a.dat3(:,2)) = 0;
  DAE.x(a.dat3(:,3)) = 0;
  DAE.x(a.dat3(:,4)) = a.u(a.ty3).*a.dat3(:,12).*a.dat3(:,6);
  DAE.f(a.dat3(:,1)) = 0;
  DAE.f(a.dat3(:,2)) = 0;
  DAE.f(a.dat3(:,3)) = 0;
  DAE.f(a.dat3(:,4)) = 0;
end
%%
if a.ty4
  
  Porder4 = Porder(a.ty4);
  Tg = a.con(a.ty4,4);  
  Gmax = a.con(a.ty4,5);
  Gmin = a.con(a.ty4,6);
  vmax = a.con(a.ty4,7);
  vmin = a.con(a.ty4,8);
  Tp = a.con(a.ty4,9);
  Tr = a.con(a.ty4,10);
  sigma = a.con(a.ty4,11);
  delta = a.con(a.ty4,12);
  Tw = a.con(a.ty4,13);
  a11 = a.con(a.ty4,14);
  a13 = a.con(a.ty4,15);
  a21 = a.con(a.ty4,16);
  a23 = a.con(a.ty4,17);
  Kp = a.con(a.ty4,18);
  Ki = a.con(a.ty4,19);
   
  ap = 1./Tp;
  ag = 1./Tg;  
  ar = 1./Tr;
  aw = 1./Tw;
  K1 = 1./a11;
  K2 = aw.*K1;
  K3 = a13.*a21./a11;
  K4 = a11.*a23-a13.*a21;
  K5 = ap.*ag;
 
  a.dat4 = [a.tg1(a.ty4), ...             %  1
            a.tg2(a.ty4), ...             %  2
            a.tg3(a.ty4), ...             %  3
            a.tg4(a.ty4), ...             %  4
            a.tg5(a.ty4), ...             %  5
            K5, ...                     %  6
            Porder4, ...                  %  7
            ap, ...                       %  8
            ar, ...                       %  9
            aw, ...                       % 10
            K1, ...                       % 11
            K2, ...                       % 12
            K3, ...                       % 13
            K4, ...                       % 14
            sigma, ...                    % 15
            delta,...                     % 16
            Kp,...                        % 17
            Ki,...                        % 18
            Tr,...                        % 19
            Syn.omega(a.syn(a.ty4)), ...  % 20
            zeros(length(a.ty4),1), ...   % 21
            zeros(length(a.ty4),1)];      % 22
            
  
  DAE.x(a.dat4(:,1)) = a.u(a.ty4).*a.dat4(:,15).*a.dat4(:,7);
  DAE.x(a.dat4(:,2)) = 0;
  DAE.x(a.dat4(:,3)) = a.u(a.ty4).*a.dat4(:,7);
  DAE.x(a.dat4(:,4)) = a.u(a.ty4).*a.dat4(:,7).*a.dat4(:,19);
  DAE.x(a.dat4(:,5)) = a.u(a.ty4).*a.dat4(:,13).*a.dat4(:,7);

  DAE.f(a.dat4(:,1)) = 0;
  DAE.f(a.dat4(:,2)) = 0;
  DAE.f(a.dat4(:,3)) = 0;
  DAE.f(a.dat4(:,4)) = 0;
  DAE.f(a.dat4(:,5)) = 0;
end
%%
if a.ty5
  Porder5 = Porder(a.ty5);
  Tg = a.con(a.ty5,4);  
  zmax = a.con(a.ty5,5);
  zmin = a.con(a.ty5,6);
  vmax = a.con(a.ty5,7);
  vmin = a.con(a.ty5,8);
  Tp = a.con(a.ty5,9);
  Tw = a.con(a.ty5,10);
  sigma = a.con(a.ty5,11);
  Kp = a.con(a.ty5,12);
  Ki = a.con(a.ty5,13);
  
  ap = 1./Tp;
  ag = 1./Tg;
  aw = 1./Tw;
  
 
  a.dat5 = [a.tg1(a.ty5), ...             %  1
            a.tg2(a.ty5), ...             %  2
            a.tg3(a.ty5), ...             %  3
            a.tg4(a.ty5), ...             %  4
            ag, ...                       %  5
            Porder5, ...                  %  6
            ap, ...                       %  7
            aw, ...                       %  8
            Kp,...                        %  9
            Ki,...                        % 10
            sigma, ...                    % 11
            Syn.omega(a.syn(a.ty5)), ...  % 12
            zeros(length(a.ty5),1), ...   % 13
            zeros(length(a.ty5),1)];      % 14        
  
  DAE.x(a.dat5(:,1)) = 0;
  DAE.x(a.dat5(:,2)) = a.u(a.ty5).*a.dat5(:,6);
  DAE.x(a.dat5(:,3)) = a.u(a.ty5).*a.dat5(:,6);
  DAE.x(a.dat5(:,4)) = a.u(a.ty5).*a.dat5(:,6);
  
  DAE.f(a.dat5(:,1)) = 0;
  DAE.f(a.dat5(:,2)) = 0;
  DAE.f(a.dat5(:,3)) = 0;
  DAE.f(a.dat5(:,4)) = 0;
end
%%
if a.ty6
  Porder6 = Porder(a.ty6);
  Ka = a.con(a.ty6,4);  
  Gmax = a.con(a.ty6,5);
  Gmin = a.con(a.ty6,6);
  vmax = a.con(a.ty6,7);
  vmin = a.con(a.ty6,8);
  Ta = a.con(a.ty6,9);
  Tw = a.con(a.ty6,10);
  beta = a.con(a.ty6,11);
  Kp = a.con(a.ty6,12);
  Ki = a.con(a.ty6,13);
  Kd = a.con(a.ty6,14);
  Td = a.con(a.ty6,15);
  Rp = a.con(a.ty6,16);  

  ad = 1./Td;
  aa = 1./Ta;
  aw = 1./Tw;
  K1 = Kd.*ad;
  K2 = K1.*ad;
%   K3 = (Gmax-Gmin).*Settings.mva./getvar(Syn,a.syn(a.ty6),'mva');
  K3 = (Gmax-Gmin);
  K4 = Ka.*aa;
  DAE.f(Syn.omega)=0;
 
  a.dat6 = [a.tg1(a.ty6), ...             %  1
            a.tg2(a.ty6), ...             %  2
            a.tg3(a.ty6), ...             %  3
            a.tg4(a.ty6), ...             %  4
            a.tg5(a.ty6), ...             %  5
            K4, ...                       %  6
            Porder6, ...                  %  7
            ad, ...                       %  8
            aa, ...                       %  9
            aw, ...                       % 10
            K1, ...                       % 11
            K2, ...                       % 12
            K3, ...                       % 13
            Kp, ...                       % 14
            Ki, ...                       % 15
            beta, ...                     % 16
            Rp, ...                       % 17
            DAE.x(Syn.omega(a.syn(a.ty6))), ...  % 18
            zeros(length(a.ty6),1), ...   % 19
            zeros(length(a.ty6),1), ...  % 20
            DAE.f(Syn.omega(a.syn(a.ty6))), ...% 21
            DAE.y(Syn.p(a.syn(a.ty6)))];  % 22         
      
              
  DAE.x(a.dat6(:,1)) = a.u(a.ty6).*a.dat6(:,7).*a.dat6(:,13);
  DAE.x(a.dat6(:,2)) = 0;
  DAE.x(a.dat6(:,3)) = 0;
  DAE.x(a.dat6(:,4)) = a.u(a.ty6).*a.dat6(:,7).*a.dat6(:,13);
  DAE.x(a.dat6(:,5)) = a.u(a.ty6).*a.dat6(:,7);
  
  DAE.f(a.dat6(:,1)) = 0;
  DAE.f(a.dat6(:,2)) = 0;
  DAE.f(a.dat6(:,3)) = 0;
  DAE.f(a.dat6(:,4)) = 0;
  DAE.f(a.dat6(:,5)) = 0;
end


%%
Syn.pm0(a.syn(find(a.u))) = 0;
DAE.y(a.wref) = a.u.*a.con(:,3);

maxlmt = find(Porder > a.con(:,5));
minlmt = find(Porder < a.con(:,6));
for i = 1:length(maxlmt)
  fm_disp(['Pmech greater than maximum limit for TG #', ...
           num2str(maxlmt(i))],1)
end
for i = 1:length(minlmt)
  fm_disp(['Pmech less than minimum limit for TG #', ...
           num2str(minlmt(i))],1)
end
if isempty(maxlmt) && isempty(minlmt)
  fm_disp('Initialization of Turbine Gorvernors completed.',1)
else
  fm_disp('Initialization of Turbine Gorvernors failed.',2)
  return
end

