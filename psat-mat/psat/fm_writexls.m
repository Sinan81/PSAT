function fm_writexls(Matrix,Header,Cols,Rows,File)
% FM_WRITEXLS export PSAT results to an Microsoft Excel
%             spreadsheet using Matlab ActiveX interface.
%             Microsoft Excel is required.
%
%             This function is based on xlswrite.m by Scott Hirsch
%
% FM_WRITEXLS(MATRIX,HEDAER,COLNAMES,ROWNAMES,FILENAME)
%
%    MATRIX     Matrix to write to file
%               Cell array for multiple matrices.
%    HEADER     String of header information.
%               Cell array for multiple header.
%    COLNAMES   (Cell array of strings) Column headers.
%               One cell element per column.
%    ROWNAMES   (Cell array of strings) Row headers.
%               One cell element per row.
%    FILENAME   (string) Name of Excel file.
%               If not specified, contents will be
%               opened in Excel.
%
%Author:    Federico Milano
%Date:      13-Sep-2003
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

% Open Excel, add workbook, change active worksheet,
% get/put array, save.
% First, open an Excel Server.
Excel = actxserver('Excel.Application');

% If the user does not specify a filename, we'll make Excel
% visible if they do, we'll just save the file and quit Excel
% without ever making it visible
%if nargin < 5
  set(Excel, 'Visible', 1);
%end;

% Insert a new workbook.
Workbooks = Excel.Workbooks;
Workbook = invoke(Workbooks, 'Add');

% Make the first sheet active.
Sheets = Excel.ActiveWorkBook.Sheets;
sheet1 = get(Sheets, 'Item', 1);
invoke(sheet1, 'Activate');

% Get a handle to the active sheet.
Activesheet = Excel.Activesheet;

% --------------------------------------------------------------------
% writing data
% --------------------------------------------------------------------

nhr = 0;

for i_matrix = 1:length(Matrix)

  m = Matrix{i_matrix};
  colnames = Cols{i_matrix};
  rownames = Rows{i_matrix};
  header = Header{i_matrix};

  [nr,nc] = size(m);
  if nc > 256
    fm_disp(['Matrix is too large.  Excel only supports 256' ...
	     ' columns'],2)
    delete(Excel)
    return
  end

  % Write header
  % -----------------------------------------------------------------

  if ~isempty(header)
    if iscell(header)
      % Number header rows
      for ii=1:length(header)
        jj = nhr + ii;
        ActivesheetRange = get(Activesheet, ...
                               'Range', ...
                               ['A',num2str(jj)], ...
                               ['A',num2str(jj)]);
        set(ActivesheetRange, 'Value', header{ii});
      end
      nhr = nhr + length(header);
    else
      % Number header rows
      nhr = nhr + 1;
      hcol = ['A',num2str(nhr)];
      ActivesheetRange = get(Activesheet,'Range',hcol,hcol);
      set(ActivesheetRange, 'Value', header);
    end
  end

  %Add column names
  % -----------------------------------------------------------------

  if nargin > 2 && ~isempty(colnames)
    [nrows,ncolnames] = size(colnames);
    for hh = 1:nrows
      nhr = nhr + 1;
      for ii = 1:ncolnames
        colname = localComputLastCol('A',ii);
        cellname = [colname,num2str(nhr)];
        ActivesheetRange = get(Activesheet,'Range',cellname,cellname);
        set(ActivesheetRange, 'Value', colnames{hh,ii});
      end
    end
  end

  % Put a MATLAB array into Excel.
  % -----------------------------------------------------------------

  % Data start right after the headers
  FirstRow = nhr + 1;
  LastRow = FirstRow + nr - 1;

  % First column depends on the dimension of rownames

      [nrownames,ncols] = size(rownames);
  if nargin < 3 || isempty(rownames)
    FirstCol = 'A';
  elseif isempty(colnames)
    FirstCol = 'D';
  else
    switch ncols
     case 1, FirstCol = 'B';
     case 2, FirstCol = 'C';
     case 3, FirstCol = 'D';
     case 4, FirstCol = 'E';
     case 5, FirstCol = 'F';
     otherwise, FirstCol = 'G';
    end
  end

  if ~isempty(m)
    LastCol = localComputLastCol(FirstCol,nc);
    ActivesheetRange = get(Activesheet,'Range', ...
                                       [FirstCol,num2str(FirstRow)], ...
                                       [LastCol,num2str(LastRow)]);
    set(ActivesheetRange,'Value',full(m));
  end

  %Add row names
  % -----------------------------------------------------------------

  if nargin > 3 && ~isempty(rownames)
    %nrownames = length(rownames);
    for ii = 1:nrownames
      for jj = 1:ncols
	switch jj
	 case 1, Col = 'A';
	 case 2, Col = 'B';
	 case 3, Col = 'C';
	 case 4, Col = 'D';
	 case 5, Col = 'E';
	 otherwise, Col = 'F';
	end
	%rowname = localComputLastCol('A',FirstRow+ii-1);
	cellname = [Col,num2str(FirstRow + ii - 1)];
	ActivesheetRange = get(Activesheet,'Range',cellname,cellname);
	set(ActivesheetRange, 'Value', rownames{ii,jj});
      end
    end
  end

  % add a blank row in between data
  % -----------------------------------------------------------------

  nhr = LastRow + 1;

end

% If user specified a filename, save the file and quit Excel
% -------------------------------------------------------------------

if nargin == 5
  invoke(Workbook, 'SaveAs', [Path.data,File]);
  %invoke(Excel, 'Quit');
  fm_disp(['Excel file ',Path.data,File,' has been created.']);
end

%Delete the ActiveX object
% -------------------------------------------------------------------

delete(Excel)

% Local functions
% -------------------------------------------------------------------

function LastCol = localComputLastCol(FirstCol,nc);
% Compute the name of the last column where we will place data
% Input:
%  FirstCol  (string) name of first column
%  nc        total number of columns to write

% Excel's columns are named:
% A B C ... A AA AB AC AD .... BA BB BC ...

% Offset from column A
FirstColOffset = double(FirstCol) - double('A');

% Easy if single letter
% Just convert to ASCII code, add the number of needed columns,
% and convert back to a string

if nc<=26-FirstColOffset
  LastCol = char(double(FirstCol)+nc-1);
else
  % Number of groups (of 26)
  ng = ceil(nc/26);
  % How many extra in this group beyond A
  rm = rem(nc,26)+FirstColOffset;
  LastColFirstLetter = char(double('A') + ng-2);
  LastColSecondLetter = char(double('A') + rm-1);
  LastCol = [LastColFirstLetter LastColSecondLetter];
end;