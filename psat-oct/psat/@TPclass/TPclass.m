function a = TPclass(varargin)
% constructor of the Tap Changer with embedded load
% == Tap ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.m = [];
  a.u = [];
  a.ncol = 13;
  a.format = ['%4d ',repmat('%8.4g ',1,11),'%2u'];
  a.store = [];
  if Settings.matlab, a = class(a,'TPclass'); end
 case 1
  if isa(varargin{1},'TPclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
