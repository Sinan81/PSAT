function  name = fvar(argom,spaces)
% FVAR creates fixed space data strings
%
% NAME = FVAR(ARGOM,SPACES)
%     ARGOM values (string or number)
%     SPACES fixed character number
%     NAME output (string)
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    08-Mar-2004
%Version:   1.1.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Settings

if isnumeric(argom)
  argom = round(argom/Settings.lftol)*Settings.lftol;
  if argom >= 0
    segno = ' ';
  else
    segno = '-';
  end
  argom = abs(argom);
  name = num2str(argom);
else
  if double(argom(1)) <= 57 && double(argom(1)) >= 48
    segno = ' ';
  else
    segno = '';
  end
  name = argom;
end

name = [segno, name, blanks(spaces)];
name = name(1:spaces);