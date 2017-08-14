% The program symfault is designed for the balanced three-phase
% fault analysis of a power system network. The program requires
% the bus impedance matrix Zbus. Zbus may be defined by the
% user, obtained by the inversion of Ybus or it may be
% determined either from the function Zbus = zbuild(zdata)
% or the function Zbus = zbuildpi(linedata, gendata, yload).
% The program prompts the user to enter the faulted bus number
% and the fault impedance Zf. The prefault bus voltages are
% defined by the reserved Vector V. The array V may be defined or
% it is returned from the power flow programs lfgauss, lfnewton,
% decouple or perturb. If V does not exist the prefault bus voltages
% are automatically set to 1.0 per unit. The program obtains the
% total fault current, the postfault bus voltages and line currents.
%
% Copyright (C) 1998 H. Saadat

function symfault(zdata, Zbus, V)

fm_var

if ~autorun('Short Circuit Analysis',0)
  return
end

if isempty(Fault.con)
  fm_disp('No fault found', 2) 
  return
end
  
zdata = Line.con;
  
[Zbus, zdata]= zbuildpi(zdata, Syn.con);
  
nl = zdata(:,1); 
nr = zdata(:,2); 
R = zdata(:,3);
X = zdata(:,4);
nc = length(zdata(1,:));
if nc > 4
  BC = zdata(:,11);
elseif nc == 4
  BC = zeros(length(zdata(:,1)), 1);
end
ZB = R + j*X

nbr = length(zdata(:,1)); 
nbus = max(max(nl), max(nr));
if exist('V') == 1
  if length(V) == nbus
    V0 = V;
  end
else
  V0 = ones(nbus, 1) + j*zeros(nbus, 1);
end
fprintf('\nThree-phase balanced fault analysis \n')

for ff = 1:Fault.n

  nf = Fault.bus(ff);    
  fprintf('Faulted bus No. = %g \n', nf)    

  fprintf('\n Fault Impedance Zf = R + j*X = ')
  Zf = Fault.con(ff,7) + j*Fault.con(ff,8);
  fprintf('%8.5f + j(%8.5f)  \n', real(Zf), imag(Zf))
  fprintf('Balanced three-phase fault at bus No. %g\n', nf)

  If = V0(nf)/(Zf + Zbus(nf, nf));
  Ifm = abs(If); 
  Ifmang = angle(If)*180/pi;
  fprintf('Total fault current = %8.4f per unit \n\n', Ifm)
  fprintf('Bus Voltages during fault in per unit \n\n')
  fprintf('     Bus     Voltage       Angle\n')
  fprintf('     No.     Magnitude     degrees\n')

  for n = 1:nbus
    if n == nf
      Vf(nf) = V0(nf)*Zf/(Zf + Zbus(nf,nf));
      Vfm = abs(Vf(nf)); 
      angv = angle(Vf(nf))*180/pi;
    else
      Vf(n) = V0(n) - V0(n)*Zbus(n,nf)/(Zf + Zbus(nf,nf));
      Vfm = abs(Vf(n)); 
      angv=angle(Vf(n))*180/pi;
    end
    fprintf('   %4g',  n), fprintf('%13.4f', Vfm),fprintf('%13.4f\n', angv)
  end
  
  fprintf('  \n')
  
  fprintf('Line currents for fault at bus No.  %g\n\n', nf)
  fprintf('     From      To     Current     Angle\n')
  fprintf('     Bus       Bus    Magnitude   degrees\n')

  for n = 1:nbus
    %Ign=0;
    for I = 1:nbr
      if nl(I) == n || nr(I) == n
        if nl(I) == n 
          k = nr(I);
        elseif nr(I) == n
          k = nl(I);
        end
        if k==0
          Ink = (V0(n) - Vf(n))/ZB(I);
          Inkm = abs(Ink);
          th = angle(Ink);
          %if th <= 0
          if real(Ink) > 0
            fprintf('      G   '), fprintf('%7g',n), fprintf('%12.4f', Inkm)
            fprintf('%12.4f\n', th*180/pi)
          elseif real(Ink) ==0 && imag(Ink) < 0
            fprintf('      G   '), fprintf('%7g',n), fprintf('%12.4f', Inkm)
            fprintf('%12.4f\n', th*180/pi)
          end
          Ign = Ink;
        elseif k ~= 0
          Ink = (Vf(n) - Vf(k))/ZB(I)+BC(I)*Vf(n);
          %Ink = (Vf(n) - Vf(k))/ZB(I);
          Inkm = abs(Ink); th=angle(Ink);
          %Ign=Ign+Ink;
          %if th <= 0
          if real(Ink) > 0
            fprintf('%7g', n)
            fprintf('%10g', k),
            fprintf('%12.4f', Inkm)
            fprintf('%12.4f\n', th*180/pi)
          elseif real(Ink) ==0 && imag(Ink) < 0
            fprintf('%7g', n)
            fprintf('%10g', k),
            fprintf('%12.4f', Inkm)
            fprintf('%12.4f\n', th*180/pi)
          end
        end
      end
    end
    
    if n == nf  % show Fault Current
      fprintf('%7g',n)
      fprintf('         F')
      fprintf('%12.4f', Ifm)
      fprintf('%12.4f\n', Ifmang)
    end
  end
  resp=0;
  %while strcmp(resp, 'n')~=1 && strcmp(resp, 'N')~=1 && strcmp(resp, 'y')~=1 && strcmp(resp, 'Y')~=1
  %resp = input('Another fault location? Enter ''y'' or ''n'' within single quote -> ');
  %if strcmp(resp, 'n')~=1 && strcmp(resp, 'N')~=1 && strcmp(resp, 'y')~=1 && strcmp(resp, 'Y')~=1
  %fprintf('\n Incorrect reply, try again \n\n'), end
  %end
  %if resp == 'y' || resp == 'Y'
  nf = 999;
  %else
  ff = 0;
  %end
  
end   % end for while

fm_disp(['Finished "',filedata,'"']),
