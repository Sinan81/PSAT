function pgrep(expression,string,options)
%PGREP change strings within files
%
%PGREP(EXPRESSION,STRING,TYPE)
%    EXPRESSION: regular expression
%    STRING: the string to be searched.
%    TYPE:   1 - list file names, row number and line text
%            2 - list file names and line text
%            3 - list file names
%            4 - as 1, but look for Matlab variables only
%            5 - as 1, but span all subdirectories
%
%see also PSED
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    18-Feb-2003
%Update:    30-Mar-2004
%Version:   1.0.2
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

if nargin < 3,
  disp('Check synthax ...')
  disp('   ')
  help pgrep,
  return,
end
if ~ischar(expression)
  disp('First argument has to be a not empty string.')
  return
end
if ~ischar(string) || isempty(string)
  disp('Second argument has to be a not empty string.')
  return
end
if ~isnumeric(options) || length(options) > 1 || rem(options,1) || ...
      options > 5 || options <= 0
  disp('Third argument has to be a scalar integer within [1-5]')
  return
end

a = dir(expression);
if isempty(a)
  disp('No file name matches the given expression.')
  return
end
file = {a.name}';
a = dir(pwd);
names = {a.name}';
isdir = [a.isdir]';
if options == 5,
  disp('  ')
  disp('Spanning directories ...')
  disp('  ')
  disp(pwd)
  file = deepdir(expression,names,file,isdir,pwd);
  options = 1;
else
  disp('  ')
  disp(pwd)
end
n_file = length(file);
if ~n_file, disp('No matches.'),
  return,
end
check = 0;
try,
  if exist('strfind');
    check = 1;
  end
catch
  % nothing to do
  % this for Octave compatibility
end

disp('  ')
disp('Scanning files ...')
disp('  ')

for i = 1:n_file
  fid = fopen(file{i}, 'rt');
  n_row = 0;
  while 1 && fid > 0
    sline = fgets(fid);
    if ~isempty(sline),
      if sline == -1,
        break;
      end
    end
    n_row = n_row + 1;
    if check
      vec = strfind(sline,string);
    else
      vec = findstr(sline,string);
    end
    if ~isempty(vec)
      switch options
       case 1
        disp([fvar(file{i},14),'  row ',fvar(int2str(n_row),5), ...
              ' >> ',sline(1:end-1)])
       case 3
        disp(file{i})
        break
       case 2
        disp([fvar(file{i},14),' >> ',sline(1:end-1)])
       case 4
        okdisp = 0;
        okdispl = 0;
        okdispr = 0;
        for j = 1:length(vec)
          if vec(j) > 1,
            ch_l = double(sline(vec(j)-1));
            if ch_l ~= 34 && ch_l ~= 39 && ch_l ~= 95 && ch_l ~= 46 && ...
                       (ch_l < 48 || (ch_l > 57 && ch_l < 65) || ...
                        (ch_l > 90 && ch_l < 97) || ch_l > 122)
              okdispl = 1;
            end
          end
          if vec(j) + length(string) < length(sline),
            ch_r = double(sline(vec(j)+length(string)));
            if ch_r ~= 34 && ch_r ~= 95 && ...
                       (ch_r < 48 || (ch_r > 57 && ch_r < 65) || ...
                        (ch_r > 90 && ch_r < 97) || ch_r > 122)
              okdispr = 1;
            end
          else
            okdispr = 1;
          end
          if okdispl && okdispr,
            okdisp = 1;
            break
          end
          okdispl = 0;
          okdispr = 0;
        end
        if okdisp,
          disp([fvar(file{i},14),'  row ',fvar(int2str(n_row),5), ...
                ' >> ',sline(1:end-1)]),
        end
      end
    end
  end
  if fid > 0,
    count = fclose(fid);
  end
end

% ----------------------------------------------------------------------
% find subdirectories
% ----------------------------------------------------------------------

function file = deepdir(expression,names,file,isdir,folder)
idx = find(isdir);
for i = 3:length(idx)
  disp([folder,filesep,names{idx(i)}])
  newfolder = [folder,filesep,names{idx(i)}];
  b = dir([newfolder,filesep,expression]);
  if ~isempty({b.name})
    bnames = {b.name};
    n = length(bnames);
    newfiles = cell(n,1);
    for k = 1:n
      newfiles{k} = [folder,filesep,names{idx(i)},filesep,bnames{k}];
    end
    file = [file; newfiles];
  end
  b = dir([newfolder]);
  newdir = [b.isdir]';
  newnames = {b.name}';
  file = deepdir(expression,newnames,file,newdir,newfolder);
end