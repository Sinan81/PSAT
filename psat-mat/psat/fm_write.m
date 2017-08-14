function fm_write(Matrix,Header,Cols,Rows)
% FM_WRITE chose function for writing PSAT outputs
%
%Author:    Federico Milano
%Date:      01-May-2006
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Settings

% determining the output file name
filename = [fm_filenum(Settings.export),['.',Settings.export]];

% select function for writing outputs
switch Settings.export
 case 'txt'
  fm_writetxt(Matrix,Header,Cols,Rows,filename)
 case 'xls'
  fm_writexls(Matrix,Header,Cols,Rows,filename)
 case 'tex'
  fm_writetex(Matrix,Header,Cols,Rows,filename)
 case 'html'
  fm_writehtm(Matrix,Header,Cols,Rows,filename)
end