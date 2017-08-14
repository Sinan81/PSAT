function fm_writetex(Matrix,Header,Cols,Rows,File)
% FM_WRITETEX export PSAT results in LaTeX2e format.
%
% FM_WRITETEX(MATRIX,HEDAER,COLNAMES,ROWNAMES,FILENAME)
%
%    MATRIX     Matrix to write to file
%               Cell array for multiple matrices.
%    HEADER     String of header information.
%               Cell array for multiple header.
%    COLNAMES   (Cell array of strings) Column headers.
%               One cell element per column.
%    ROWNAMES   (Cell array of strings) Row headers.
%               One cell element per row.
%    FILENAME   (string) Name of TeX file.
%               If not specified, contents will be
%               opened in the current selected text
%               viewer.
%
%Author:    Federico Milano
%Date:      15-Sep-2003
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

% --------------------------------------------------------------------
% opening text file
% --------------------------------------------------------------------

fm_disp
fm_disp('Writing the report LaTeX2e file...')

[fid,msg] = fopen([Path.data,File], 'wt');
if fid == -1
  fm_disp(msg)
  return
end
path_lf = strrep(Path.data,'\','\\');

% --------------------------------------------------------------------
% writing data
% --------------------------------------------------------------------

nhr = 0;
idx_table = 0;

for i_matrix = 1:length(Matrix)

  m = Matrix{i_matrix};
  colnames = Cols{i_matrix};
  rownames = Rows{i_matrix};
  header = Header{i_matrix};

  if isempty(colnames) && isempty(rownames) && isempty(m)

    % treat header as comment
    if ~isempty(header)
      if iscell(header)
        for ii = 1:length(header)
          count = fprintf(fid,'%% %s\n',specialchar(header{ii}));
        end
      else
        count = fprintf(fid,'%% %s\n',specialchar(header));
      end
    end

  else % create table

    idx_table = idx_table + 1;

    % print the preamble of the table
    % see Leslie Lamport's LATEX book for details.
    % open the table environment as a floating body
    fprintf(fid, '\\begin{table}[htbp] \n');
    fprintf(fid, ' \\begin{center} \n');

    % Write header
    % ------------------------------------------------------------------

    caption = '';
    if iscell(header)
      for ii = 1:length(header)
	caption = [caption,' ',header{ii}];
      end
    else
      caption = [caption,header];
    end
    caption = specialchar(caption);

    %% include the user-defined or default caption
    fprintf(fid, '  \\caption{%s} \n', caption);
    count = fprintf(fid,'  \\vspace{0.1cm}\n');

    % Write column names
    % ------------------------------------------------------------------

    if nargin > 2 && ~isempty(colnames)
      [nrows,ncolnames] = size(colnames);

      tt =  '|';
      for ii = 1:ncolnames
	tt = [tt,'c|'];
      end
      fprintf(fid, '  \\begin{tabular}{%s} \n', tt);
      fprintf(fid, '   \\hline \n');

      for jj = 1:nrows
	fprintf(fid, '   ');
	for ii = 1:ncolnames-1
	  count = fprintf(fid, '%s & ', specialchar(colnames{jj,ii}));
	end
	count = fprintf(fid, '%s \\\\\n', specialchar(colnames{jj,ncolnames}));
      end
      count = fprintf(fid,'   \\hline \\hline \n');
    end

    % Write data
    % ------------------------------------------------------------------

    if nargin > 3 && ~isempty(rownames)
      [nrownames,ncols] = size(rownames);
      ndata = size(m,2);

      if isempty(colnames)
	tt =  '|';
	for ii = 1:(ncols+ndata)
	  tt = [tt,'c|'];
	end
	fprintf(fid, '  \\begin{tabular}{%s} \n', tt);
	fprintf(fid, '   \\hline \n');
      end

      for ii = 1:nrownames
	fprintf(fid, '   ');
	for jj = 1:ncols
	  count = fprintf(fid, '%s & ', specialchar(rownames{ii,jj}));
	end
	for hh = 1:ndata-1
	  count = fprintf(fid, '$%8.5f$ & ', m(ii,hh));
	end
	count = fprintf(fid, '$%8.5f$ \\\\ \\hline \n', m(ii,ndata));
      end
    end

    %% print the footer of the table environment
    fprintf(fid, '  \\end{tabular} \n');
    %% include the user-defined or default label
    fprintf(fid, '  \\label{%s} \n', ...
	    ['tab:',strrep(File,'.tex',''),'_',num2str(idx_table)]);
    fprintf(fid, ' \\end{center} \n');
    %% close the table environment and return
    fprintf(fid, '\\end{table} \n');

  end
  count = fprintf(fid,'\n');

end

fclose(fid);
fm_disp(['Report of Static Results saved in ',File])

% view file
fm_text(13,[Path.data,File])


% -------------------------------------------------------
% check for special LaTeX2e character
% -------------------------------------------------------

function string = specialchar(string)

string = [lower(strrep(string,'#','\#')),' '];
string = strrep(string,'&','\&');
string = strrep(string,'_','\_');
string = strrep(string,'$','\$');
string = strrep(string,'{','\{');
string = strrep(string,'}','\}');
string = strrep(string,'%','\%');
string = strrep(string,'~','$\sim$');
string(1) = upper(string(1));