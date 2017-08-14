function fm_save(Comp)
% FM_SAVE save UDM to file
%
% FM_SAVE uses the component name COMP.NAME as file name
% and creates a Matlab script.
% The file is saved in the folder ./psat/build
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    15-Sep-2003
%Version:   2.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Settings Path Fig
global Algeb Buses Initl Param Servc State

% check for component name
if isempty(Comp.name)
  fm_disp('No component name set.',2)
  return
end

% check for older versions
a = dir([Path.build,'*.m']);
b = {a.name};
older = strmatch([Comp.name,'.m'],b,'exact');
if ~isempty(older)
  uiwait(fm_choice(['Overwrite Existing File "',Comp.name,'.m" ?']))
  if ~Settings.ok, return, end
end

% save data
if isempty(Comp.init)
  Comp.init = 0;
end
if isempty(Comp.descr)
  Comp.descr = ['DAE function ', Comp.name, '.m'];
end

[fid,msg] = fopen([Path.build,Comp.name,'.m'],'wt');
if fid == -1
  fm_disp(msg,2)
  fm_disp(['UDM File ',Comp.name,'.m couldn''t be saved.'],2)
  return
end

count = fprintf(fid,'%% User Defined Component %s\n',Comp.name);
count = fprintf(fid,'%% Created with PSAT v%s\n',Settings.version);
count = fprintf(fid,'%% \n');
count = fprintf(fid,'%% Date: %s\n',datestr(now,0));

Comp = rmfield(Comp,{'names','prop','n'});

savestruct(fid,Comp)
savestruct(fid,Buses)
savestruct(fid,Algeb)
savestruct(fid,State)
savestruct(fid,Servc)
savestruct(fid,Param)
savestruct(fid,Initl)

count = fprintf(fid,'\n');
fclose(fid);

fm_disp(['UDM File ',Comp.name,'.m saved in folder ./build'])

% update list in the component browser GUI
if ishandle(Fig.comp)
  fm_comp clist
end

% -------------------------------------------------------------------
function savestruct(fid,structdata)

if isempty(structdata)
  return
end

if ~isstruct(structdata)
  return
end

fields = fieldnames(structdata);
namestruct = inputname(2);
count = fprintf(fid,'\n%% Struct: %s\n',namestruct);

for i = 1:length(fields)

  field = getfield(structdata,fields{i});

  if isempty(field)
    count = fprintf(fid,'\n%s.%s = [];',namestruct,fields{i});
  end
  [m,n] = size(field);

  if isnumeric(field)
    for mi = 1:m
      for ni = 1:n
	count = fprintf(fid,['\n%s.%s(%d,%d) = %d;'], ...
			namestruct,fields{i},mi,ni,field(mi,ni));
      end
    end
  elseif iscell(field)
    for mi = 1:m
      for ni = 1:n
	count = fprintf(fid,['\n%s.%s{%d,%d} = ''%s'';'], ...
			namestruct,fields{i},mi,ni, ...
                        strrep(field{mi,ni},'''',''''''));
      end
    end
  elseif ischar(field)
    count = fprintf(fid,'\n%s.%s = ''%s'';', ...
                    namestruct,fields{i},strrep(field,'''',''''''));
  end
  count = fprintf(fid,'\n');

end