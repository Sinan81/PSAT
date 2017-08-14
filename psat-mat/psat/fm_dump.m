function fm_dump
% FM_DUMP dump the current data file to a file
%
%Author:    Federico Milano
%Date:      28-Nov-2008
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

fm_var

filename = [fm_filenum('m'), '.m'];
[fid,msg] = fopen([Path.data,filename], 'wt');
if fid == -1
  fm_disp(msg)
  return
end

dump_data(fid, Bus, 'Bus')
dump_data(fid, SW, 'SW')
dump_data(fid, PV, 'PV')
for i = 1:(length(Comp.names)-2)
  dump_data(fid, eval(Comp.names{i}), Comp.names{i})
end
dump_data(fid, Areas, 'Areas')
dump_data(fid, Regions, 'Regions')

dump_name(fid, Bus.names, 'Bus')
dump_name(fid, Areas.names, 'Areas')
dump_name(fid, Regions.names, 'Regions')

fclose(fid);
fm_disp(['Data dumped to file <', filename ,'>'])

function dump_data(fid, var, name)

if ~var.n, return, end
fprintf(fid, '%s.con = [ ...\n', name);
fprintf(fid, [var.format, ';\n'], var.store.');
fprintf(fid, '    ];\n\n');

function dump_name(fid, var, name)

if isempty(var), return, end
n = length(var);
count = fprintf(fid, [name,'.names = {... \n  ']);
for i = 1:n-1
  names = strrep(var{i,1},char(10),' ');
  names = strrep(var{i,1},'''','''''');
  count = fprintf(fid, ['''',names,'''; ']);
  if rem(i,5) == 0; count = fprintf(fid,'\n  '); end
end
if iscell(var)
  names = strrep(var{n,1},char(10),' ');
  names = strrep(var{n,1},'''','''''');
  count = fprintf(fid, ['''',names,'''};\n\n']);
else
  names = strrep(var,char(10),' ');
  names = strrep(var,'''','''''');
  count = fprintf(fid, ['''',names,'''};\n\n']);
end