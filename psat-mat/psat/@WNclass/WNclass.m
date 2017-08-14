function a = WNclass(varargin)
% constructor of the class Wind
% == Wind ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.speed = struct('vw',[],'time',[]);
  a.vwa = [];
  a.vw = [];
  a.ws = [];
  a.store = [];
  a.ncol = 17;
  a.format = ['%4d ',repmat('%8.4g ',1,15), '%4d'];
  if Settings.matlab, a = class(a,'WNclass'); end
 case 1
  if isa(varargin{1},'WNclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
