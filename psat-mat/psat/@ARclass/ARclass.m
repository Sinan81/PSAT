function a = ARclass(varargin)
% constructor of the class AREAS and REGIONS
% == Areas & Regions ==

global Settings

switch nargin
 case 0
  a.type = 'area'; % by default define Areas
  a.con = [];
  a.n = 0;
  a.bus = cell(0,0);
  a.slack = [];
  a.store = [];
  a.names = cell(0,0);
  a.int = [];
  a.ncol = 8;
  a.format = '%4d %4d %8.4g %8.4g %8.4g %8.5g %8.5g %8.5g';
  if Settings.matlab, a = class(a,'ARclass'); end
 case 1
  if isa(varargin{1},'ARclass')
    a = varargin{1};
  elseif ischar(varargin{1}) 
    a.type = varargin{1};
    if ~sum(strcmp({'area','region'},a.type))
      a.type = 'area'; % by default define Areas
    end
    a.con = [];
    a.n = 0;
    a.bus = cell(0,0);
    a.slack = [];
    a.store = [];
    a.names = cell(0,0);
    a.int = [];
    a.ncol = 8;
    a.format = '%4d %4d %8.4g %8.4g %8.4g %8.5g %8.5g %8.5g';
    if Settings.matlab, a = class(a,'ARclass'); end
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
