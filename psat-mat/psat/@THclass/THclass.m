function a = THclass(varargin)
% constructor of the Thermostatically Controlled Load
% == Thermostatically Controlled Load ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.T = [];
  a.G = [];
  a.x = [];
  a.u = [];
  a.ncol = 12;
  a.format = ['%4d ',repmat('%8.4g ',1,10),'%2u'];
  a.store = [];
  if Settings.matlab, a = class(a,'THclass'); end
 case 1
  if isa(varargin{1},'THclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
