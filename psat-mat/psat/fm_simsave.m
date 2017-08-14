function fm_simsave(varargin)
% FM_SIMSAVE attempts to save the current Simulink model to
%            Simulink 3 (R11) or, if it is not possible, to the
%            oldest supported Simulink release.
%
%            This functions calls UIGETFILE to chose a Simulink
%            model. At the end of the procedure, the original file
%            will subsituted with the new one.
%
%Author:    Federico Milano
%Date:      07-Aug-2003
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Path Settings

if exist('simulink') ~= 5
  fm_choice('Simulink is not available on this system',2);
  return
end

if Settings.hostver < 7
  fm_choice('This function runs only under Matlab 7.x or newer',2)
  return
end

switch nargin
 case 0,
  [filename, pathname] = uigetfile('*.mdl', ...
                                   'Chose Simulink Model...');
 case 1,
  if ~strcmp(varargin{1},'all'), return, end
  foldername = uigetdir(Path.local);
  a = dir([foldername,filesep,'*.mdl']);
  names = {a.name};
  for i = 1:length(names)
    fm_simsave(names{i},foldername);
  end
  return
 otherwise,
  filename = varargin{1};
  pathname = varargin{2};
end

if isequal(pathname,0), return, end

modelname = strrep(filename,'.mdl','');

currentpath = pwd;

cd(pathname)

fm_disp(['Model ', modelname,' will be saved in Simulink 5.1 (R13SP1) format.'])
load_system(modelname);
save_system(modelname,modelname,'','R13SP1');

cd(currentpath)