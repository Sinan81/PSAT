% The program symfault is designed for the balanced three-phase
% fault analysis of a power system network. 
%
% Input:
% 1)The program requires the bus impedance matrix Zbus.
% Zbus may be defined by the
% user, obtained by the inversion of Ybus or it may be
% determined either from the function Zbus = zbuild(zdata)
% or the function Zbus = zbuildpi(linedata, gendata, yload).
%
% The program prompts the user to enter the faulted bus number
% and the fault impedance Zf. 
%
% The prefault bus voltages are defined by the reserved Vector V.
% The array V may be defined or it is returned from the power flow
% programs. If V does not exist the prefault bus voltages
% are automatically set to 1.0 per unit.
%
% output:
% The program obtains the total fault current, the postfault bus voltages
% and line currents.
%
% Copyright (C) 1998 H. Saadat
% edit By S. Majid Shariatzadeh
%

%function symfault(zdata, Zbus, V)
function symfault () % no input argument  

fm_var % define PSAT global variables such as setting

%if ~autorun('Short Circuit Analysis',0)
%  return
%end

if isempty(Syn.con) 
  fm_disp('No generator found', 2) 
  return
else
  genData=Syn.con;   
end

nbus = Bus.n;
if isempty(Fault.con)
  fm_disp('Short Circuit calculations is performed for each bus', 2) 
  FaultIfm=zeros(1,nbus);
  FaultIfmang=zeros(1,nbus);  
  Fault.bus=1:nbus ; % simulate fault in all bus
  Faultn=nbus;
  %return
else
  FaultIfm=zeros(1,Fault.n); % simulate fault in all faulty bus
  FaultIfmang=zeros(1,Fault.n);  
  Faultn=Fault.n;   %number of fault in circuit 
end
 
%  
% if exist('V') == 1
%   if length(V) == nbus
%     V0 = V;
%   end
% else
%   V0 = ones(nbus, 1) + j*zeros(nbus, 1);
% end

zdata = Line.con;
yload =Pl ;
[Zbus, zdata]= zbuildpi(zdata,genData ,yload);
  
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
%nbus = max(max(nl), max(nr));

if exist('V') == 1
  if length(V) == nbus
    V0 = V;
  end
else
  V0 = ones(nbus, 1) + j*zeros(nbus, 1);
end

fprintf('\nThree-phase balanced fault analysis \n')

for ff = 1:Faultn

  nf = Fault.bus(ff); 
  faultbusname=Bus.names{nf};
  fprintf('\n\n\n\Faulted bus  = %s \n',faultbusname )    
  if isempty(Fault.con) 
      Zf = 0.001;
  else 
      Zf = Fault.con(ff,7) + j*Fault.con(ff,8);
  end
  
  fprintf('\nFault Impedance Zf = R + j*X = ')      
  fprintf('%8.5f + j(%8.5f)  \n', real(Zf), imag(Zf))
  busname=Bus.names{nf};
  fprintf('Balanced three-phase fault at %s\n\n', busname)
  
  If = V0(nf)/(Zf + Zbus(nf, nf));
  Ifm = abs(If); 
  Ifmang = angle(If)*180/pi;
  fprintf('Total fault current = %8.4f per unit \n\n\n\n', Ifm)  
  fprintf('Calculations Detali:\n\n')  
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
    fprintf('   %7s',  Bus.names{n}), fprintf('%13.4f', Vfm),fprintf('%13.4f\n', angv)
  end
  
  fprintf('  \n')
  
  fprintf('Line currents for fault at   %s\n\n', faultbusname)
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
            fprintf('      G   '), fprintf('%7s',Bus.names{n}), fprintf('%12.4f', Inkm)
            fprintf('%12.4f\n', th*180/pi)
          elseif real(Ink) ==0 && imag(Ink) < 0
            fprintf('      G   '), fprintf('%7s',Bus.names{n}), fprintf('%12.4f', Inkm)
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
            fprintf('%7s', Bus.names{n})
            fprintf('%10g', k),
            fprintf('%12.4f', Inkm)
            fprintf('%12.4f\n', th*180/pi)
          elseif real(Ink) ==0 && imag(Ink) < 0
            fprintf('%7s', Bus.names{n})
            fprintf('%10g', k),
            fprintf('%12.4f', Inkm)
            fprintf('%12.4f\n', th*180/pi)
          end
        end
      end
    end
    
    if n == nf  % show Fault Current
      fprintf('%7s',Bus.names{n})
      fprintf('         F')
      fprintf('%12.4f', Ifm)
      fprintf('%12.4f\n', Ifmang)
	  FaultIfm(n)=Ifm;
      FaultIfmang(n)=Ifmang;
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

%% generate report

fprintf('  \n')
if isempty(Fault.con)
      fprintf('-----------------------------------\n')
      fprintf('Bus currents for fault at each bus:\n\n')

      fprintf('     From      To     Current     Angle\n')
      fprintf('     Bus       Bus    Magnitude   degrees\n')

      for n = 1:nbus
          faultbusname=Bus.names{n};          
          fprintf('%7s', faultbusname);
          fprintf('       Ground');
          fprintf('%12.4f', FaultIfm(n));
          fprintf('%12.4f\n', FaultIfmang(n));

      end

else
    
      nfault=Fault.n;
      fprintf('-----------------------------------\n')
      fprintf('Bus currents for fault at selected bus:\n\n')

      fprintf('     From      To     Current     Angle\n')
      fprintf('     Bus       Bus    Magnitude   degrees\n')
      
      for ff = 1:Fault.n;
          nf = Fault.bus(ff);
          for n = 1:nbus
               if n==nf 
                  faultbusname=Bus.names{n};
                  fprintf('%7s',faultbusname);
                  fprintf('       Ground');
                  fprintf('%12.4f', FaultIfm(n));
                  fprintf('%12.4f\n', FaultIfmang(n));
               end   
          end
      end  

    
end 
fm_disp(['--']),



  % initialize report structures
  Header{1,1}{1,1}  = 'PSAT+';
  Header{1,1}{2,1}  = 'SHORT CIRCUIT REPORT';
  Header{1,1}{3,1} = ' ';  
  Cols{1,1}{1,1}= ' '; %no other data
  Rows{1,1}{1,1} =' ';%no other data
  Matrix{1,1} = ' ';%no other data

% %  Header{1,1}{3,1} = ['P S A T + ',Settings.version];
   Header{1,1}{4,1} = ' ';
   Header{1,1}{5,1} = 'Author:  Majid Shariatzadeh, (c) 2018-2020';
   Header{1,1}{6,1} = 'e-mail:  m.shariatzadeh@yahoo.com';
 %  Header{1,1}{7,1} = 'website: faraday1.ucd.ie/psat.html';
   Header{1,1}{8,1} = ' ';
   Header{1,1}{9,1} = ['File:  ', Path.data,strrep(File.data,'(mdl)','.mdl')];
   Header{1,1}{10,1} = ['Date:  ',datestr(now,0)];



% writing data as a matrix...
%
%    MATRIX     Matrix to write to file
%               Cell array for multiple matrices.
%    HEADER     String of header information.
%               Cell array for multiple header.
%    COLNAMES   (Cell array of strings) Column headers.
%               One cell element per column.
%    ROWNAMES   (Cell array of strings) Row headers.
%               One cell element per row.
  
% fm_write(Matrix,Header,Cols,Rows)  
%fm_write(Matrix,Header,Cols,Rows)  
       
if isempty(Fault.con)
      Header{2,1}{1,1}= '-----------------------------------';
      Header{2,1}{2,1}= 'Bus currents for fault at each bus:';
      Header{2,1}{3,1}= ' ';
      

      Cols{2,1}{1,1}= 'From Bus';
      Cols{2,1}{1,2}= 'To Bus';      
      Cols{2,1}{1,3}= 'Current (PU)';            
      Cols{2,1}{1,4}= 'Angle degrees';                  
      
      for n = 1:nbus
              nf = n;  
              ff=n;
              faultbusname=Bus.names{n};          
              Rows{2,1}{ff,1}= faultbusname;
              Rows{2,1}{ff,2}= 'Ground';
              MatrixOut(ff,1)= FaultIfm(n);
              MatrixOut(ff,2)= FaultIfmang(n);

      end
      Matrix {2,1}=MatrixOut;
else
    
      nfault=Fault.n;
      Header{2,1}{1,1}= '-----------------------------------';
      Header{2,1}{2,1}= 'Bus currents for fault at selected bus:';
      Header{2,1}{3,1}= ' ';
 % MatrixOut=zeros(nbus,4);
      Cols{2,1}{1,1}= 'From Bus';
      Cols{2,1}{1,2}= 'To Bus';   
      Cols{2,1}{1,3}= 'Current (PU)';
      Cols{2,1}{1,4}= 'Angle degrees'; 
      for ff = 1:Fault.n;
          nf = Fault.bus(ff);      
              for n = 1:nbus
                if n==nf                   
                  faultbusname=Bus.names{n};          
                  Rows{2,1}{ff,1}= faultbusname;
                  Rows{2,1}{ff,2}= 'Ground';
                  MatrixOut(ff,1)= FaultIfm(n);
                  MatrixOut(ff,2)= FaultIfmang(n);
                end
              end
      end
      Matrix {2,1}=MatrixOut;

    
end             
fm_write(Matrix,Header,Cols,Rows)    ;   
       


       
       
       
end % end of function




