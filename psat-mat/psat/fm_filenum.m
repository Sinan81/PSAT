function nome = fm_filenum(varargin)
% FM_FILENUM determine names for output report files.
%            Files are number from 00 to 99.
%            After the 99th file is created, file 00
%            is rewritten without asking foir permission.
%
% NAME = FM_FILENUM(EXT)
%      EXT string defining the file extension
%      NAME resulting file name
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global File Path

if nargin == 1

  extension = varargin{1};
  nome = strrep(File.data,'(mdl)','');
  if strcmp(nome([1:2]),'@ '),
  nome = nome(3:end);
  end
  counter = 1;
  numero = '_01';
  localpath = pwd;
  cd(Path.data)
  while exist([nome,numero,'.',extension]) == 2
    counter = counter + 1;
    if counter < 10
    numero = ['_0',int2str(counter)];
    elseif counter < 100
      numero = ['_',int2str(counter)];
    else
      numero = '_01'; break
    end
  end
  cd(localpath)
  nome = [nome, numero];

elseif nargin == 2

  nome = varargin{1};
  % check for Matlab operators within function name
  list = {'+','-','*','/','\','.','@','%','$', ...
          '|','!','(',')','=','>','<','[',']', ...
          '#','&','{','}','?',':',',',';','"', ...
          '~','^',' ',''''};
  for i = 1:length(list)
    nome = strrep(nome,list{i},'_');
  end

end