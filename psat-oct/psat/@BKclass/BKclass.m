function a = BKclass(varargin)
% constructor of the class Breaker
% == Breaker ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.line = [];
  a.store = [];
  a.u = [];
  a.ncol = 10;
  a.t1 = [];
  a.t2 = [];
  a.time = inf;
  a.format = ['%4d %4d ',repmat('%8.4g ',1,6),'%2d %2d'];
  if Settings.matlab, a = class(a,'BKclass'); end
 case 1
  if isa(varargin{1},'BKclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
