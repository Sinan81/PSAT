function fm_uninstall
% FM_UNINSTALL remove an user defined component
%
% FM_UNINSTALL
%
%see also FM_INSTALL, FM_MAKE, FM_BUILD
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Algeb Buses Initl Param Servc State
global Fig Comp Settings Path

error_vect = [];
error_number = 0;
lasterr('');
if ~ishandle(Fig.update), Fig.update = fm_update; end
string_update = cell(13,1);
hdl_lista = findobj(Fig.update,'Tag','Listbox1');
if strcmp(Path.psat(1),'~')
  pathpsat = [getenv('HOME'),Path.psat(2:end)];
else
  pathpsat = Path.psat;
end

% structure and file names
c_name = lower(Comp.name);
c_name(1) = upper(c_name(1));
f_name = ['fm_',lower(Comp.name)];

string_update{1,1} = ['Erasing "fm_', Comp.name, '.m" settings from system files...'];
set(hdl_lista,'String',string_update);


% ************************************************************************************
% update file comp.ini
file = textread([pathpsat,'comp.ini'],'%s','delimiter','\n','whitespace','');
fid = fopen([pathpsat,'comp.ini'],'wt');
nrows = length(file);
form = '%s\n';
for i = 1:nrows
  if i == nrows, form = '%s'; end
  if isempty(findstr(file{i},f_name)), fprintf(fid,form,file{i}); end
end
fclose(fid);
string_update{2,1} = 'System file "comp.ini" updated.';
set(hdl_lista,'String',string_update);


% ************************************************************************************
% update function fm_ncomp.m
file = textread([pathpsat,'fm_ncomp.m'],'%s','delimiter','\n','whitespace','');
fid = fopen([pathpsat,'fm_ncomp.m'],'wt');
c2 = 1;
nrows = length(file);
form = '%s\n';
for i = 1:nrows
  if i == nrows, form = '%s'; end
  c1 = isempty(findstr(file{i},c_name));
  if ~c1 && c2, c2 = 0; end
  c3 = isempty(findstr(file{i},'end'));
  if c2, fprintf(fid,form,file{i}); end
  if ~c3 && ~c2, c2 = 1; end
end
fclose(fid);
string_update{3,1} = 'System file "fm_ncomp.m" updated.';
set(hdl_lista,'String',string_update);


% ************************************************************************************
% update function fm_inilf.m
file = textread([pathpsat,'fm_inilf.m'],'%s','delimiter','\n','whitespace','');
fid = fopen([pathpsat,'fm_inilf.m'],'wt');
nrows = length(file);
form = '%s\n';
for i = 1:nrows
  if i == nrows, form = '%s'; end
  if isempty(findstr(file{i},c_name)), fprintf(fid,form,file{i}); end
end
fclose(fid);
string_update{4,1} = 'System file "fm_inilf.m" updated.';
set(hdl_lista,'String',string_update);


% ************************************************************************************
% update function fm_var.m
file = textread([pathpsat,'fm_var.m'],'%s','delimiter','\n','whitespace','');
fid = fopen([pathpsat,'fm_var.m'],'wt');
nrows = length(file);
form = '%s\n';
for i = 1:nrows
  if i == nrows, form = '%s'; end
  c1 = isempty(findstr(file{i},c_name));
  c2 = isempty(findstr(file{i},Comp.descr)) || length(file{i}) < length(Comp.descr);
  if c1 && c2, fprintf(fid,form,file{i}); end
end
fclose(fid);
string_update{5,1} = 'System file "fm_var.m" updated.';
set(hdl_lista,'String',string_update);


% ************************************************************************************
% update file namevarx.ini
file = textread([pathpsat,'namevarx.ini'],'%s','delimiter','\n','whitespace','');
fid = fopen([pathpsat,'namevarx.ini'],'wt');
nrows = length(file);
form = '%s\n';
for i = 1:nrows
  if i == nrows, form = '%s'; end
  if isempty(findstr(file{i},c_name)), fprintf(fid,form,file{i}); end
end
fclose(fid);
string_update{6,1} = 'Data file "namevarx.ini" updated.';
set(hdl_lista,'String',string_update);


% ************************************************************************************
% update function fm_dynlf.m
file = textread([pathpsat,'fm_dynlf.m'],'%s','delimiter','\n','whitespace','');
fid = fopen([pathpsat,'fm_dynlf.m'],'wt');
c2 = 1;
n = 0;
nrows = length(file);
form = '%s\n';
for i = 1:nrows
  if i == nrows, form = '%s'; end
  c1 = isempty(findstr(file{i},c_name));
  if ~c1 && c2, c2 = 0; end
  c3 = isempty(findstr(file{i},'end'));
  if c2, fprintf(fid,form,file{i}); end
  if ~c3 && ~c2, n=n+1; end
  if n == 2, c2 = 1; end
end
fclose(fid);
string_update{7,1} = 'System file "fm_dynlf.m" updated.';
set(hdl_lista,'String',string_update);


% ************************************************************************************
% update function fm_dynidx.m
file = textread([pathpsat,'fm_dynidx.m'],'%s','delimiter','\n','whitespace','');
fid = fopen([pathpsat,'fm_dynidx.m'],'wt');
c2 = 1;
n = 0;
nrows = length(file);
form = '%s\n';
for i = 1:nrows
  if i == nrows, form = '%s'; end
  c1 = isempty(findstr(file{i},c_name));
  if ~c1 && c2, c2 = 0; end
  c3 = isempty(findstr(file{i},'end'));
  if c2, fprintf(fid,form,file{i}); end
  if ~c3 && ~c2, n=n+1; end
  if n == 2, c2 = 1; end
end
fclose(fid);
string_update{8,1} = 'System file "fm_dynidx.m" updated.';
set(hdl_lista,'String',string_update);


% ************************************************************************************
% update script file Contents.m
file = textread([pathpsat,'Contents.m'],'%s','delimiter','\n','whitespace','');
fid = fopen([pathpsat,'Contents.m'],'wt');
nrows = length(file);
form = '%s\n';
for i = 1:nrows
  if i == nrows, form = '%s'; end
  if isempty(findstr(file{i},f_name)), fprintf(fid,form,file{i}); end
end
fclose(fid);
string_update{9,1} = 'Contents file for on line help updated.';
set(hdl_lista,'String',string_update);


% ************************************************************************************
% no need of updating file service.ini:
string_update{10,1} = 'File Data "service.ini" updated.';
set(hdl_lista,'String',string_update);


% ************************************************************************************
% update function fm_xfirst.m
file = textread([pathpsat,'fm_xfirst.m'],'%s','delimiter','\n','whitespace','');
fid = fopen([pathpsat,'fm_xfirst.m'],'wt');
c2 = 1;
nrows = length(file);
form = '%s\n';
for i = 1:nrows
  if i == nrows, form = '%s'; end
  c1 = isempty(findstr(file{i},c_name));
  if ~c1 && c2, c2 = 0; end
  c3 = isempty(findstr(file{i},'end'));
  if c2, fprintf(fid,form,file{i}); end
  if ~c3 && ~c2, c2 = 1; end
end
fclose(fid);
string_update{11,1} = 'System file "fm_xfirst.m" updated.';
set(hdl_lista,'String',string_update);

% ************************************************************************************
% update script file psat.m
file = textread([pathpsat,'psat.m'],'%s','delimiter','\n','whitespace','');
fid = fopen([pathpsat,'psat.m'],'wt');
nrows = length(file);
form = '%s\n';
for i = 1:nrows
  if i == nrows, form = '%s'; end
  if isempty(findstr(file{i},c_name)), fprintf(fid,form,file{i}); end
end
fclose(fid);
string_update{12,1} = 'File Data "psat.m" updated.';
set(hdl_lista,'String',string_update);


% ****************************************************************************************
% update structure Varname
Varname.unamex = '';
Varname.fnamex = '';
Varname.compx = '';
Varname.unamey = '';
Varname.fnamey = '';
Varname.compy = '';

failed = 0;
fid = fopen([pathpsat,'namevarx.ini'], 'rt');
if fid == -1,
  failed = 1;
else
  nname = 0;
  while 1
    sline = fgetl(fid);
    if ~ischar(sline), break; end
    try
      Varname.unamex{nname+1,1} = deblank(sline(1:20));
      Varname.fnamex{nname+1,1} = deblank(sline(21:40));
      Varname.compx{nname+1,1}  = deblank(sline(41:end));
      nname = nname + 1;
    end
  end
  count = fclose(fid);
  string_update{13,1} = 'Structure "Varname" updated.';
end
if failed
  string_update{13,1} = 'Error: Structure "Varname" could not be updated.';
else
  string_update{13,1} = 'Structure "Varname" updated.';
end
set(hdl_list,'String',string_update);


% *************************************************************************
% update structure Comp
Comp.names = '';
Comp.prop = '';
Comp.n = 0;
fid = fopen([pathpsat,'comp.ini'], 'rt');
if fid == -1,
  string_update{14,1} = 'Error: Structure "Comp" could not be updated.';
else
  ncomp=0;
  while 1
    sline = fgetl(fid);
    if ~ischar(sline), break; end
    try
      Comp.names{ncomp+1,1} = deblank(sline(1:21));
      Comp.prop(ncomp+1,:) = str2num(sline(22:38));
      ncomp=ncomp+1;
    end
  end
  count = fclose(fid);
  Comp.names{ncomp+1} = 'PV';
  Comp.prop(ncomp+1,:) = [2 1 0 0 0 1 0 0];
  Comp.names{ncomp+2} = 'SW';
  Comp.prop(ncomp+2,:) = [2 1 0 0 0 1 0 0];
  Comp.n = ncomp+2;
  string_update{14,1} = 'Structure "Comp" updated.';
end
set(hdl_list,'String',string_update);

% last operations
string_update{end+1,1} = ['Component ',c_name,' uninstalled.'];
set(hdl_lista,'String',string_update);