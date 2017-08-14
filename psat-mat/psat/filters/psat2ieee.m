function check = psat2ieee(varargin)
% PSAT2IEEE converts PSAT data file into IEEE Common Data Format
%
% CHECK = PSAT2IEEE(FILENAME,PATHNAME)
%       FILENAME name of the file to be converted
%       PATHNAME path of the file to be converted
%
%       CHECK = 1 conversion completed
%       CHECK = 0 problem encountered (no data file created)
%
%Author:    Federico Milano
%Date:      11-Nov-2002
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

if nargin == 2
  filename = varargin{1};
  pathname = varargin{2};
  nopowers = 0;
elseif nargin == 3
  filename = varargin{1};
  pathname = varargin{2};
  nopowers = varargin{3};
else
  check = 0;
  return
end

if strcmp(pathname(end),filesep)
  pathname = pathname(1:end-1);
end
if ~strcmp(pathname,pwd)
  cd(pathname)
end

fm_disp
fm_disp(['Opening PSAT file "',filename,'"...'])

% General Settings
% ----------------------------------------------------------------

check = 1;
b128 = [blanks(128),'\n'];
b12 = blanks(12);

% Defining local data structures
% ----------------------------------------------------------------

Bus = BUclass;
Twt = TWclass;
Line = LNclass;
Shunt = SHclass;
SW = SWclass;
PV = PVclass;
PQ = PQclass;
PQgen = PQclass;

% Reading Data from PSAT Data File
% ----------------------------------------------------------------

a = exist(filename);
if a == 2,
  eval(filename(1:end-2))
  if nopowers
    PQ = pqzero(PQ,'all');
    PV = pvzero(PV,'all');
    SW = swzero(SW,'all');
  end
else,
  fm_disp(['File "',pathname,filesep,filename,'" not found or not an m-file'],2)
  check = 0;
  return
end

% Completing data settings
% ---------------------------------------------------------------

Bus = setup(Bus);
Line = setup(Line,Bus);
Twt = setup(Twt,Bus,Line);
Shunt = setup(Shunt,Bus);
PV = setup(PV,Bus);
SW = setup(SW,Bus,PV);
PQ = setup(PQ,Bus);
PQgen = setup(PQgen,Bus);
PQ = addgen(PQ,PQgen,Bus);

% Checking max bus number
% ----------------------------------------------------------------------

if Bus.n > 9999 && Bus.n <= 99999
  fm_disp(['The number of buses is > 9999. Extended IEEE CDF will be ' ...
           'used.'])
end
if Bus.n > 99999
  fm_disp(['Network dimension is too big for IEEE-CDF (max bus number ' ...
           '= 99999).'],2)
  check = 0;
  return
end

% Opening File
% ----------------------------------------------------------------------

newfile = [filename(1:end-2),'.cf'];
fm_disp(['Writing IEEE CDF file "',newfile,'"...'])
fid = fopen([pathname,filesep, newfile], 'wt');

% Title Data
% ----------------------------------------------------------------------
card_I = b128;
card_I(2:9)   = datestr(now,2);           % date MM/DD/YY
card_I(11:22) = 'PSAT ARCHIVE';           % originator name
card_I(32:37) = '100.00';                 % MVA base
card_I(39:42) = datestr(now,10);          % year YYYY
s = str2num(datestr(now,5));
if s > 3 && s < 10, card_I(44) = 'S'; else, card_I(44) = 'W'; end % Season
a1 = [num2str(Bus.n),'-Bus ',num2str(Line.n),'-Line System',blanks(28)];
card_I(46:73) = a1(1:28);                           % Case Identification
count = fprintf(fid,card_I);

% Bus Data
% ---------------------------------------------------------------------

% Section Start card
card_b = b128;
card_b(1:15) = 'BUS DATA FOLLOW';
nbus = [num2str(Bus.n),' ITEMS'];
card_b(41:41+length(nbus)-1) = nbus;
count = fprintf(fid,card_b);

vbus = Bus.con(:,3);
abus = Bus.con(:,4);

idxPV = [];
idxPQ = [];
idxSW = [];
idxSH = [];

% Bus Data Cards
for i = 1:Bus.n

  idxPV = findbus(PV,i);
  idxPQ = findbus(PQ,i);
  idxSW = findbus(SW,i);
  if ~isempty(Shunt.con), idxSH = find(Shunt.bus == i); end

  a1 = sprintf('%5d',Bus.int(Bus.con(i,1)));
  if strcmp(a1(1),' ')
    a1 = [a1(2:5),' '];
  end
  a2 = [Bus.names{i},b12];
  a2 = a2(1:11);

  if ~isempty(idxSW),
    a3 = '3';
    a6 = sprintf('%8.3f%8.3f',100*[SW.con(idxSW,10), 0.000]);
    vbus(i) = SW.con(idxSW,4);
    abus(i) = SW.con(idxSW,5);
    a8 = sprintf('%6.4f',vbus(i));
    qmax = 100*SW.con(idxSW,6);
    qmin = 100*SW.con(idxSW,7);
    if qmax > 9999,  qmax = 9999; end
    if qmin < -9999, qmin = -9999; end
    a9 = sprintf('%8.2f%8.2f',[qmax, qmin]);
  elseif ~isempty(idxPV),
    a3 = '2';
    vbus(i) = PV.con(idxPV,5);
    a6 = sprintf('%8.3f%8.3f',100*[PV.con(idxPV,4),0.000]);
    a8 = sprintf('%6.4f',vbus(i));
    qmax = 100*PV.con(idxPV,6);
    qmin = 100*PV.con(idxPV,7);
    if qmax > 9999,  qmax = 9999; end
    if qmin < -9999, qmin = -9999; end
    a9 = sprintf('%8.2f%8.2f',[qmax, qmin]);
  elseif ~isempty(idxPQ),
    a3 = '1';
    a6 = sprintf('%8.3f%8.3f',[0.000, 0.000]);
    a8 = sprintf('%6.4f',1.00);
    a9 = sprintf('%8.2f%8.2f',[0.000, 0.000]);
  else,
    a3 = '0';
    a6 = sprintf('%8.3f%8.3f',[0.000, 0.000]);
    a8 = sprintf('%6.4f',1.00);
    a9 = sprintf('%8.2f%8.2f',[0.000, 0.000]);
  end

  a4 = sprintf('%6.4f%7.3f',[vbus(i),180*abus(i)/pi]);

  if ~isempty(idxPQ)
    a5 = sprintf('%9.4f%10.4f',100*PQ.con(idxPQ,[4,5]));
  else
    a5 = sprintf('%9.4f%10.4f',[0.0000, 0.0000]);
  end

  a7 = sprintf('%7.2f',Bus.con(i,2));

  if ~isempty(idxSH)
    a10 = sprintf('%8.4f%8.4f',Shunt.con(idxSH,[5,6]));
  else
    a10 = sprintf('%8.4f%8.4f',[0.0000, 0.0000]);
  end

  a11 = sprintf('%4d',i);

  card = [a1,' ',a2,'  1  0  ',a3,' ',a4,a5,a6,' ',a7,' ',a8,a9,a10,' ',a11,'\n'];
  count = fprintf(fid,card);
end

% Section End Card
count = fprintf(fid,'-999\n');

% Branch Data
% --------------------------------------------------------------------

% Section Start card
card_l = b128;
card_l(1:18) = 'BRANCH DATA FOLLOW';
nline = [num2str(Line.n),' ITEMS'];
card_l(41:41+length(nline)-1) = nline;
count = fprintf(fid,card_l);

% Line Data Cards
for i = 1:Line.n
  if Line.con(i,1) < 10000 && Line.con(i,2) < 10000
    a1 = sprintf('%4d %4d  1 1  1 ',Line.con(i,[1 2]));
  elseif Line.con(i,1) < 10000 && Line.con(i,2) >= 10000
    a1 = sprintf('%4d %5d 1 1  1 ',Line.con(i,[1 2]));
  elseif Line.con(i,1) >= 10000 && Line.con(i,2) < 10000
    a1 = sprintf('%5d%4d  1 1  1 ',Line.con(i,[1 2]));
  else
    a1 = sprintf('%5d%5d 1 1  1 ',Line.con(i,[1 2]));
  end
  tap = Line.con(i,11);
  if tap == 1, tap = 0; end
  if Line.con(i,7) || tap || Line.con(i,12)
    if tap == 0, tap = 1; end
    a2 = '1';
    a5 = sprintf('%4d 0  %6.4f %7.3f%7.4f%7.4f %6.4f ', ...
                 [Line.con(i,2),tap,Line.con(i,12),0,0,0]);
  else
    a2 = '0';
    a5 = sprintf('%4d 0  %6.4f %7.3f%7.4f%7.4f %6.4f ', ...
                 [0,tap,Line.con(i,12),0,0,0]);
  end
  a3 = sprintf(' %9.7f %10.8f %9.7f',Line.con(i,[8 9 10]));
  Ilim = round(Line.con(i,13)*100);
  %Ilims = [num2str(Ilim),'     '];
  %Ilims = Ilims([1:5]);
  %a4 = sprintf([Ilims,' %5d %5d '],[0 0]);
  a4 = sprintf('%5d %5d %5d ',[Ilim 0 0]);
  a6 = sprintf('%7.4f%7.4f',[0.0000, 0.0000]);
  card = [a1,a2,a3,a4,a5,a6];
  count = fprintf(fid,[card,'\n']);
end

% Section End Card
count = fprintf(fid,'-999\n');

% Loss Zone Data
% --------------------------------------------------------------------

% Section Start card
card_l = b128;
card_l(1:17) = 'LOSS ZONES FOLLOW';
card_l(41:47) = '1 ITEMS';
count = fprintf(fid,card_l);

% Loss Zone Cards
a1 = [num2str(Bus.n),'-Bus',b12];
a1 = a1(1:12);
count = fprintf(fid,['  1 ',a1,'\n']);

% Section End Card
count = fprintf(fid,'-99\n');

% Interchange Data
% ------------------------------------------------------------------

% Section Start card
card_l = b128;
card_l(1:23) = 'INTERCHANGE DATA FOLLOW';
card_l(41:47) = '1 ITEMS';
count = fprintf(fid,card_l);

% Interchange Data Cards
a1 = sprintf('%4d',Bus.int(Bus.con(SW.bus(1),1)));
a2 = [Bus.names{SW.bus(1)},b12];
a2 = a2(1:12);
a3 = sprintf('%8.2f %6.2f  ',[0.00 999.99]);
a4 = [num2str(Bus.n),'Bus   '];
a4 = a4(1:6);
a5 = [num2str(Bus.n),'-Bus ',num2str(Line.n),'-Line System',blanks(30)];
a5 = a5(1:30);
count = fprintf(fid,[' 1 ',a1,' ',a2,a3,a4,'  ',a5,'\n']);

% Section End Card
count = fprintf(fid,'-9\n');

% Tie Line Data
% -----------------------------------------------------------------

% Section Start card
card_l = b128;
card_l(1:16) = 'TIE LINES FOLLOW';
card_l(41:47) = '0 ITEMS';
count = fprintf(fid,card_l);

% Tie Line Cards
% NO DATA

% Section End Card
count = fprintf(fid,'-999\n');
count = fprintf(fid,'END OF DATA ');

% Closing the file
% ----------------------------------------------------------------

fclose(fid);
DAE = DAE_old;
Varname = Varname_old;
Settings = Settings_old;
fm_disp('Conversion completed.')