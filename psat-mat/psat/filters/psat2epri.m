function check = psat2epri(filename, pathname)
% PSAT2EPRI converts PSAT data file into EPRI Data Format
%
% CHECK = PSAT2EPRI(FILENAME,PATHNAME)
%       FILENAME name of the file to be converted
%       PATHNAME path of the file to be converted
%
%       CHECK = 1 conversion completed
%       CHECK = 0 problem encountered (no data file created)
%
%Author:    Federico Milano
%Date:      06-Oct-2003
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2009 Federico Milano

global DAE Varname Settings

DAE_old = DAE;
Varname_old = Varname;
Settings_old = Settings;

if strcmp(pathname(end),filesep)
  pathname = pathname(1:end-1);
end
if ~strcmp(pathname,pwd)
  cd(pathname)
end

fm_disp
fm_disp(['Opening PSAT file "',filename,'"...'])

% General Settings
% -----------------------------------------------------------

check = 1;
b128 = [blanks(128),'\n'];
b12 = blanks(12);

% Defining local data structures
% -----------------------------------------------------------

Bus = BUclass;
Twt = TWclass;
Line = LNclass;
Shunt = SHclass;
SW = SWclass;
PV = PVclass;
PQ = PQclass;
PQgen = PQclass;
Ltc = LTclass;
Phs = PHclass;

% Reading Data from PSAT Data File
% -----------------------------------------------------------

a = exist(filename);
if a == 2,
  eval(filename(1:end-2))
else,
  fm_disp(['File "',filename,'" not found or not an m-file'],2)
  check = 0;
  return
end

% Completing data settings
% -----------------------------------------------------------

Bus = setup(Bus);
Line = setup(Line,Bus);
Twt = setup(Twt,Bus,Line);
Shunt = setup(Shunt,Bus);
PV = setup(PV,Bus);
SW = setup(SW,Bus,PV);
PQ = setup(PQ,Bus);
PQgen = setup(PQgen,Bus);
PQ = addgen(PQ,PQgen,Bus);
Ltc = setup(Ltc,Bus);
Phs = setup(Phs,Bus);

% Opening File
% -----------------------------------------------------------

newfile = [filename(1:end-2),'.wsc'];
fm_disp(['Writing WSCC file "',newfile,'"...'])
fid = fopen([pathname,filesep, newfile], 'wt');
comment = ['C\nC',repmat('*',1,79),'\nC\n'];
count = fprintf(fid,comment);

% Header and Title
% -----------------------------------------------------------

count = fprintf(fid,'HDG\n');
count = fprintf(fid,['PSAT ARCHIVE\n']);
count = fprintf(fid,[num2str(Bus.n),'-Bus ', ...
                    num2str(Line.n),'-Line System\n']);
count = fprintf(fid,[date,'\n']);
count = fprintf(fid,'BAS\n');
count = fprintf(fid,comment);

% Bus Data
% -----------------------------------------------------------

% Section Start card
idxPV = [];
idxPQ = [];
idxSW = [];
idxSH = [];
Busnames = cell(Bus.n,1);

% Scan each bus for data
for i = 1:Bus.n

  % the following lines ensure that bus names
  % are unique and with no repetitions
  busname = Bus.names{i};
  if length(busname) > 8,
    busname = busname([1:8]);
  end
  idx = strmatch(busname,Bus.names);
  if length(idx) > 1
    idx = find(idx == i);
    nn = length(num2str(idx));
    busname([(end-idx+1):end]) = num2str(idx);
  end
  busname = [busname,blanks(8)];
  busname = busname([1:8]);
  Busnames{i,1} = busname;

  count = fprintf(fid,'B');

  idxPV = findbus(PV,i);
  idxPQ = findbus(PQ,i);
  idxSW = findbus(SW,i);
  if ~isempty(Shunt.con)
    idxSH = find(Shunt.bus == i);
  end

  % Bus type
  if ~isempty(idxSW)
    count = fprintf(fid,'S    ');
    slackname = busname;
    slackkV = Bus.con(i,2);
    slackang = SW.con(idxSW,5);
  elseif ~isempty(idxPV)
    if PV.con(idxPV,6) == 0 && PV.con(idxPV,7) == 0
      count = fprintf(fid,'E    ');
    else
      count = fprintf(fid,'Q    ');
    end
  elseif ~isempty(idxPQ)
    if PQ.con(idxPQ,6) == 0 && PQ.con(idxPQ,7) == 0
      count = fprintf(fid,'     ');
    else
      count = fprintf(fid,'V    ');
      PQ.con(idxPQ,4) = PQ.con(idxPQ,4);
      PQ.con(idxPQ,5) = PQ.con(idxPQ,5);
    end
  else
    count = fprintf(fid,'     ');
  end

  % Bus name, voltage rate and zone
  kV = Bus.con(i,2);
  count = fprintf(fid,['%s',tr(kV,4),'  '],busname,kV);

  % Load powers
  if ~isempty(idxPQ)
    P = PQ.con(idxPQ,4)*PQ.con(idxPQ,2);
    Q = PQ.con(idxPQ,5)*PQ.con(idxPQ,2);
    count = fprintf(fid,[tr(P,5),tr(Q,5)],P,Q);
  else
    count = fprintf(fid,blanks(10));
  end

  % Shunts
  if ~isempty(idxSH)
    G = Shunt.con(idxSH,5)*Shunt.con(idxSH,2)/(Shunt.con(idxSH,3)^2);
    B = Shunt.con(idxSH,6)*Shunt.con(idxSH,2)/(Shunt.con(idxSH,3)^2);
    count = fprintf(fid,[tr(G,4),tr(B,4)],G,B);
  else
    count = fprintf(fid,blanks(8));
  end

  % Generator powers and limits
  if ~isempty(idxPV)
    PM = PV.con(idxPV,2);
    Pg = PV.con(idxPV,4)*PV.con(idxPV,2);
    count = fprintf(fid,[tr(PM,4),tr(Pg,5)],PM,Pg);
    if PV.con(idxPV,6) ~= 0 || PV.con(idxPV,7) ~= 0
      QM = PV.con(idxPV,6)*PV.con(idxPV,2);
      Qm = PV.con(idxPV,7)*PV.con(idxPV,2);
      if QM < Qm
        dummy = QM;
        QM = Qm;
        Qm = dummy;
      end
      count = fprintf(fid,[tr(QM,5),tr(Qm,5)],QM,Qm);
    else
      count = fprintf(fid,blanks(10));
    end
  elseif ~isempty(idxSW)
    PM = SW.con(idxSW,2);
    Pg = SW.con(idxSW,10)*SW.con(idxSW,2);
    count = fprintf(fid,[tr(PM,4),tr(Pg,5)],PM,Pg);
    if SW.con(idxSW,6) ~= 0 || SW.con(idxSW,7) ~= 0
      QM = SW.con(idxSW,6)*SW.con(idxSW,2);
      Qm = SW.con(idxSW,7)*SW.con(idxSW,2);
      if QM < Qm
        dummy = QM;
        QM = Qm;
        Qm = dummy;
      end
      count = fprintf(fid,[tr(QM,5),tr(Qm,5)],QM,Qm);
    else
      count = fprintf(fid,blanks(10));
    end
  else
    count = fprintf(fid,blanks(19));
  end

  % Desired or maximum voltage
  if ~isempty(idxPV)
    count = fprintf(fid,'%-4.2f',PV.con(idxPV,5));
  elseif ~isempty(idxSW)
    count = fprintf(fid,'%-4.2f',SW.con(idxSW,4));
  elseif ~isempty(idxPQ)
    if PQ.con(idxPQ,6) ~= 0
      count = fprintf(fid,'%-4.2f',PQ.con(idxPQ,6));
    else
      count = fprintf(fid,blanks(4));
    end
  else
    count = fprintf(fid,blanks(4));
  end

  % Minimum voltage
  if ~isempty(idxPQ)
    if PQ.con(idxPQ,7) ~= 0
      count = fprintf(fid,'%-4.2f',PQ.con(idxPQ,7));
    else
      count = fprintf(fid,blanks(4));
    end
  else
    count = fprintf(fid,blanks(4));
  end

  % Remote name, kV and %Q are not Used by PSAT
  % ...

  % End of line
  count = fprintf(fid,'\n');

end
count = fprintf(fid,comment);

% Line and transformer data
% -----------------------------------------------------------

% Scan each line for data
for i = 1:Line.n
  m = Line.con(i,1);
  n = Line.con(i,2);
  if Line.con(i,7)
    count = fprintf(fid,'T     ');
  else
    count = fprintf(fid,'L     ');
  end
  count = fprintf(fid,'%s',Busnames{m});
  count = fprintf(fid,tr(Bus.con(m,2),4),Bus.con(m,2));
  count = fprintf(fid,' %s',Busnames{n});
  count = fprintf(fid,tr(Bus.con(n,2),4),Bus.con(n,2));
  if Line.con(i,7)
    In = Line.con(i,3);
  else
    In = Line.con(i,3)*1e3/Line.con(i,4)/sqrt(3);
  end
  count = fprintf(fid,['  ',tr(In,4)],In);

  R = Line.con(i,8);
  X = Line.con(i,9);
  B = Line.con(i,10)/2;

  count = fprintf(fid,' %-6.4f%-6.4f%-6.4f%-6.4f',R,X,0.0,B);

  if Line.con(i,7)
    if Line.con(i,11)
      T = Line.con(i,11)*Line.con(i,4);
      count = fprintf(fid,'%-5.2f',T);
      T = Line.con(i,4)/Line.con(i,7);
      count = fprintf(fid,'%-5.2f',T);
    end
  else
    if Line.con(i,6)
      % conversion to miles
      L = Line.con(i,6)*0.621371;
      count = fprintf(fid,tr(L,4),L);
    end
  end

  count = fprintf(fid,'\n');
end

% End line data
count = fprintf(fid,comment);

% Regulating Transformer Data
% -----------------------------------------------------------

for i = 1:Ltc.n
  switch Ltc.con(i,16)
   case 1, count = fprintf(fid,'R     ');
   case 2, count = fprintf(fid,'RQ    ');
   case 3, count = fprintf(fid,'R     ');
  end
  m = Ltc.bus1(i);
  n = Ltc.bus2(i);
  k = Ltc.busc;
  count = fprintf(fid,'%s',Busnames{m});
  count = fprintf(fid,tr(Bus.con(m,2),4),Bus.con(m,2));
  count = fprintf(fid,' %s',Busnames{n});
  count = fprintf(fid,tr(Bus.con(n,2),4),Bus.con(n,2));
  count = fprintf(fid,'%s',Busnames{k});
  count = fprintf(fid,tr(Bus.con(k,2),4),Bus.con(k,2));
  count = fprintf(fid,'%-5.2f%-5.2f', ...
		  Ltc.con(i,9)*Bus.con(m,2), ...
		  Ltc.con(i,10)*Bus.con(m,2));
  if Ltc.con(i,11)
    ntap = (Ltc.con(i,9)-Ltc.con(i,10))/Ltc.con(i,11);
  else
    ntap = 11;
  end
  count = fprintf(fid,tr(ntap,2),ntap);
  if Ltc.con(i,16) == 2
    count = fprintf(fid,tr(Ltc.con(i,12),5),Ltc.con(i,12));
  end
end
for i = 1:Phs.n
  count = fprintf(fid,'RP    ');
  m = Phs.bus1(i);
  n = Phs.bus2(i);
  count = fprintf(fid,'%s',Busnames{m});
  count = fprintf(fid,tr(Bus.con(m,2),4),Bus.con(m,2));
  count = fprintf(fid,' %s',Busnames{n});
  count = fprintf(fid,tr(Bus.con(n,2),4),Bus.con(n,2));
  count = fprintf(fid,'%s',Busnames{n});
  count = fprintf(fid,tr(Bus.con(n,2),4),Bus.con(n,2));
  count = fprintf(fid,'%-5.2f%-5.2f', ...
		  Phs.con(i,13)*180/pi, ...
		  Phs.con(i,14)*180/pi);
  count = fprintf(fid,'%d',11);
  count = fprintf(fid,tr(Phs.con(i,10),5),Phs.con(i,10));
end
if Ltc.n || Phs.n
  % End of regulating transformer data
  count = fprintf(fid,comment);
end

% Area Data
% -----------------------------------------------------------

% ... PSAT does not currently support areas ...

% Solution control data
% -----------------------------------------------------------

count = fprintf(fid,['SOL',blanks(20)]);
count = fprintf(fid,'%-5i  ',Settings.lfmit);
count = fprintf(fid,'%s',slackname);
count = fprintf(fid,tr(slackkV,4),slackkV);
count = fprintf(fid,'   %-10.4f\n',slackang);

% Closing the file
% -----------------------------------------------------------
count = fprintf(fid,'ZZ\n');
count = fprintf(fid,'END\n');
fclose(fid);
DAE = DAE_old;
Varname = Varname_old;
Settings = Settings_old;
fm_disp('Conversion completed.')
if Settings.beep, beep, end

% -----------------------------------------------------------
function string = tr(value,n)

threshold = 10^(n-2);

if value >= threshold || value < 0
  string = '0';
else
  string = '1';
end
string = ['%-',num2str(n),'.',string,'f'];