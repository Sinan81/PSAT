function fm_writetxt(Matrix,Header,Cols,Rows,File)
% FM_WRITETXT export PSAT results to a plain ASCII file.
%
% FM_WRITETXT(MATRIX,HEDAER,COLNAMES,ROWNAMES,FILENAME)
%
%    MATRIX     Matrix to write to file
%               Cell array for multiple matrices.
%    HEADER     String of header information.
%               Cell array for multiple header.
%    COLNAMES   (Cell array of strings) Column headers.
%               One cell element per column.
%    ROWNAMES   (Cell array of strings) Row headers.
%               One cell element per row.
%    FILENAME   (string) Name of text file.
%               If not specified, contents will be
%               opened in the current selected text
%               viewer.
%
%Author:    Federico Milano
%Date:      14-Sep-2003
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Path

if ~iscell(Matrix)
  Matrix{1,1} = Matrix;
  Header{1,1} = Header;
  Cols{1,1} = Cols;
  Rows{1,1} = Rows;
end

if strcmp(Header{1,1}{1,1},'EIGENVALUE REPORT')
  Eigs = 1;
  num = 18;
else
  Eigs = 0;
  num = 12;
end

% --------------------------------------------------------------------
% opening text file
% --------------------------------------------------------------------

fm_disp
fm_disp('Opening the report file...')

[fid,msg] = fopen([Path.data,File], 'wt');
if fid == -1
  fm_disp(msg)
  return
end

% --------------------------------------------------------------------
% writing data
% --------------------------------------------------------------------

nhr = 0;

for i_matrix = 1:length(Matrix)

  m = Matrix{i_matrix};
  colnames = Cols{i_matrix};
  rownames = Rows{i_matrix};
  header = Header{i_matrix};

  % Write header
  % ------------------------------------------------------------------

  if ~isempty(header)
    if iscell(header)
      for ii = 1:length(header)
        count = fprintf(fid,'%s\n',header{ii});
      end
    elseif ~isempty(header)
      count = fprintf(fid,'%s\n',header);
    end
    count = fprintf(fid,'\n');
  end

  % Write column names
  % ------------------------------------------------------------------

  if nargin > 2 && ~isempty(colnames)
    [nrows,ncolnames] = size(colnames);
    for jj = 1:nrows
      for ii = 1:ncolnames
        if Eigs && i_matrix == 2 && ii == 2
          % && length({rownames{ii,:}}) == 2
          num = 28;
        elseif Eigs
          num = 15;
        else
          num = 12;
        end
        count = fprintf(fid, '%s', fvar(colnames{jj,ii},num));
      end
      count = fprintf(fid,'\n');
    end
    count = fprintf(fid,'\n');
  end

  % Write data
  % ------------------------------------------------------------------

  if nargin > 3 && ~isempty(rownames)
    [nrownames,ncols] = size(rownames);
    ndata = size(m,2);
    for ii = 1:nrownames
      for jj = 1:ncols
        if Eigs && i_matrix == 2 && jj == 2
          num = 28;
        elseif Eigs
          num = 15;
        else
          num = 12;
        end
        if isempty(colnames)
          nchar = 30;
        else
          nchar = num;
        end
        if jj == ncols, nchar = nchar - 1; end
        count = fprintf(fid, '%s ', fvar(rownames{ii,jj},nchar-1));
      end
      for hh = 1:ndata
        if Eigs
          num = 15;
        else
          num = 12;
        end
	count = fprintf(fid, '%s', fvar(m(ii,hh),num));
      end
      count = fprintf(fid,'\n');
    end
  end
  count = fprintf(fid,'\n');

end

fclose(fid);
fm_disp(['Report of Static Results saved in text file "',Path.data,File,'" '])

% view file
fm_text(13,[Path.data,File])