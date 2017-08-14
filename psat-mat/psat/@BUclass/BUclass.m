function a = BUclass(varargin)
% constructor of the class BUS
% == Bus ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.int = [];
  a.a = [];
  a.v = [];
  a.Pg = [];
  a.Qg = [];
  a.Pl = [];
  a.Ql = [];
  a.island = [];
  a.names = cell(0,0);
  a.ncol = 6;
  a.format = '%4d %8.4g %8.5g %8.5g %4u %4u';
  a.store = [];
  if Settings.matlab, a = class(a,'BUclass'); end
 case 1
  if isa(varargin{1},'BUclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
