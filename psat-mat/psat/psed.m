function psed(expression,string1,string2,type)
%PSED change strings within files
%
%PSED(EXPRESSION,STRING1,STRING2,TYPE)
%    EXPRESSION: regular expression
%    STRING1: the string to be changed.
%    STRING2: the new string
%    TYPE:    1 - change all the occurrence
%             2 - change only Matlab variable type
%             3 - as 2 but no file modifications
%             4 - as 1 but span all subdirectories
%
%see also PGREP
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

if nargin < 4,
  disp('Check synthax ...')
  disp('  ')
  help psed,
  return,
end
if ~ischar(expression)
  disp('First argument (EXPRESSION) has to be a string.')
  return
end
if ~ischar(string1) || isempty(string1),
  disp('Second argument (STRING1) has to be a string.')
  return
end
if ~ischar(string2)
  disp('Third argument (STRING2) has to be a string.')
  return
end
if isempty(string2)
  string2 = '';
end
if ~isnumeric(type) || length(type) > 1 || rem(type,1) || type > 4 || ...
      type <= 0
  disp('Fourth argument has to be a scalar integer [1-4]')
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
if type == 4,
  disp(' ')
  disp('Spanning directories ...')
  disp('  ')
  disp(pwd)
  file = deepdir(expression,names,file,isdir,pwd);
  type = 1;
else
  disp('   ')
  disp(pwd)
end

n_file = length(file);
if ~n_file, disp('No matches.'),
  return,
end

tipo = type;
if tipo == 3,
  tipo = 2;
end
trova = 0;
try,
  if exist('strfind');
    trova = 1;
  end
catch
  % nothing to do
  % this is for Octave compatibility
end

disp('   ')
disp('Scanning files ...')
disp('  ')

for i = 1:n_file

  fid = fopen(file{i}, 'rt');
  n_row = 0;
  match = 0;

  while 1 && fid > 0

    sline = fgetl(fid);
    if ~isempty(sline),
      if sline == -1,
        break;
      end
    end
    n_row = n_row + 1;
    if trova
      vec = strfind(sline,string1);
    else
      vec = findstr(sline,string1);
    end
    slinenew = sline;

    if ~isempty(vec)

      switch tipo
       case 1

        match = 1;
        slinenew = strrep(sline,string1,string2);
        disp([fvar(file{i},14),'  row ',fvar(int2str(n_row),5), ...
              ' >> ',slinenew(1:end)])
        disp(['                             ',sline])

       case 2

        ok = 0;
        okdisp = 0;
        okdispl = 0;
        okdispr = 0;
        count = 0;
        for j = 1:length(vec)
          if vec(j) > 1,
            ch_l = double(sline(vec(j)-1));
            if ch_l ~= 34 && ch_l ~= 39 && ch_l ~= 95 && ...
                       ch_l ~= 46 && (ch_l < 48 || (ch_l > 57 && ch_l < 65) || ...
                                     (ch_l > 90 && ch_l < 97) || ch_l > 122)
              okdispl = 1;
            end
          else
            okdispl = 1;
          end
          if vec(j) + length(string1) < length(sline),
            ch_r = double(sline(vec(j)+length(string1)));
            if ch_r ~= 34 && ch_r ~= 95 && ...
                       (ch_r < 48 || (ch_r > 57 && ch_r < 65) || ...
                        (ch_r > 90 && ch_r < 97) || ch_r > 122)
              okdispr = 1;
            end
          else
            okdispr = 1;
          end
          if okdispl && okdispr, okdisp = 1; end
          okdispl = 0;
          okdispr = 0;
          if okdisp
            count = count + 1;
            iniz = vec(j)-1+(count-1)*(length(string2)-length(string1));
            slinenew = [slinenew(1:iniz),string2, ...
                        sline(vec(j)+length(string1):end)];
            ok = 1;
          end
          okdisp = 0;
        end
        if ok,
          disp([fvar(file{i},14),'  row ',fvar(int2str(n_row),5), ...
                ' >> ',slinenew(1:end)])
          disp(['                         ',sline])
          match = 1;
        end
      end
    end
    newfile{n_row,1} = slinenew;
  end
  if fid > 0,
    count = fclose(fid);
  end

  if match && type ~= 3
    fid = fopen(file{i}, 'wt');
    if fid > 0
      for i = 1:n_row-1,
        count = fprintf(fid,'%s\n',deblank(newfile{i}));
      end
      count = fprintf(fid,'%s',deblank(newfile{n_row}));
      count = fclose(fid);
    end
  end
end

% ---------------------------------------------------------------------
% find subdirectories
% ---------------------------------------------------------------------
function file = deepdir(expression,names,file,isdir,folder)
idx = find(isdir);
for i = 3:length(idx)
  disp([folder,filesep,names{idx(i)}])
  newfolder = [folder,filesep,names{idx(i)}];
  b = dir([newfolder,filesep,expression]);
  if ~isempty({b.name}),
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