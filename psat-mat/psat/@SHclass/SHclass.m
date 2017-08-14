function a = SHclass(varargin)
% constructor of the class Shunt
% == Shunt ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.u = [];
  a.store = [];
  a.ncol = 7;
  a.format = ['%4d ',repmat('%8.4g ',1,5),'%2u'];
  if Settings.matlab, a = class(a,'SHclass'); end
 case 1
  if isa(varargin{1},'SHclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
