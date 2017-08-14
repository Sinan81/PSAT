function a = TCclass(varargin)
% constructor of the class TCSC
% == TCSC ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus1 = [];
  a.bus2 = [];
  a.v1 = [];
  a.v2 = [];
  a.line = [];
  a.ty1 = [];
  a.ty2 = [];
  a.store = [];
  a.x1 = [];
  a.x2 = [];
  a.B = [];
  a.Cp = [];
  a.x0 = [];
  a.pref = [];
  a.X0 = [];
  a.Pref = [];
  a.y = [];
  a.u = [];
  a.ncol = 17;
  a.format = ['%4d %4d %4d %4d ',repmat('%8.4g ',1,12),'%2u'];
  if Settings.matlab, a = class(a,'TCclass'); end
 case 1
  if isa(varargin{1},'TCclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
