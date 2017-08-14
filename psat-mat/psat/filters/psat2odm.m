function check = psat2odm(varargin)
% PSAT2ODM converts PSAT data file into Open Data Format
%
% CHECK = PSAT2ODM(FILENAME,PATHNAME)
%       FILENAME name of the file to be converted
%       PATHNAME path of the file to be converted
%
%       CHECK = 1 conversion completed
%       CHECK = 0 problem encountered (no data file created)
%
%Author:    Federico Milano
%Date:      24-May-2008
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
  tag = 'pss';
elseif nargin == 3
  filename = varargin{1};
  pathname = varargin{2};
  nopowers = varargin{3};
  tag = 'pss';
elseif nargin == 4
  filename = varargin{1};
  pathname = varargin{2};
  nopowers = varargin{3};
  tag = varargin{4};
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

% Setting up local classes
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

% Opening File
% ---------------------------------------------------------------

newfile = [filename(1:end-2),'.xml'];
fm_disp(['Writing ODM file "',newfile,'"...'])
fid = fopen([pathname,filesep, newfile], 'wt');

% Header
% ---------------------------------------------------------------

count = fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
count = fprintf(fid,'<%s:PSSStudyCase>\n',tag);
count = fprintf(fid,'  <%s:id>PSAT-%dBus-System</%s:id>\n',tag,Bus.n,tag);
count = fprintf(fid,'  <%s:schemaVersion>V1.00</%s:schemaVersion>\n',tag,tag);
count = fprintf(fid,'  <%s:originalFormat>IEEE-ODM-PSS</%s:originalFormat>\n',tag,tag);
count = fprintf(fid,'  <%s:analysisCategory>Powerflow</%s:analysisCategory>\n',tag,tag);
count = fprintf(fid,'  <%s:networkCategory>Transmission</%s:networkCategory>\n',tag,tag);
count = fprintf(fid,'  <%s:baseCase>\n',tag);
count = fprintf(fid,'    <%s:id>Base-Case</%s:id>\n',tag,tag);
count = fprintf(fid,'    <%s:basePower>%7.2f</%s:basePower>\n',tag,Settings.mva,tag);
count = fprintf(fid,'    <%s:basePowerUnit>MVA</%s:basePowerUnit>\n',tag,tag);
count = fprintf(fid,'    <%s:baseFrequency>%7.2f</%s:baseFrequency>\n',tag,Settings.freq,tag);
count = fprintf(fid,'    <%s:baseFrequencyUnit>Hz</%s:basePowerFrequency>\n',tag,tag);

% Bus List
% ---------------------------------------------------------------

count = fprintf(fid,'    <%s:busList>\n',tag);

for idx = 1:Bus.n
  count = fprintf(fid,'      <%s:bus>\n',tag);
  odm(Bus,fid,tag,idx,'        ')
  count = fprintf(fid,'        <%s:loadflowBusData>\n',tag);
  odm(SW,fid,tag,idx,'        ')
  odm(PV,fid,tag,idx,'        ')
  odm(PQ,fid,tag,idx,'        ')
  count = fprintf(fid,'        </%s:loadflowBusData>\n',tag);
  count = fprintf(fid,'      </%s:bus>\n',tag);
end

count = fprintf(fid,'    </%s:busList>\n',tag);

% Branch List
% ---------------------------------------------------------------

count = fprintf(fid,'    <%s:branchList>\n',tag);

odm(Line,fid,tag,'      ');

count = fprintf(fid,'    </%s:branchList>\n',tag);

% Closing the file
% ---------------------------------------------------------------

count = fprintf(fid,'  </%s:baseCase>\n',tag);
count = fprintf(fid,'</%s:PSSStudyCase>\n',tag);
fclose(fid);
DAE = DAE_old;
Varname = Varname_old;
Settings = Settings_old;
fm_disp('Conversion completed.')