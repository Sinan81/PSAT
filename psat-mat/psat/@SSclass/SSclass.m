function a = SSclass(varargin)
% constructor of the class SSSC
% == SSSC ==

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
  a.vcs = [];
  a.vpi = [];
  a.store = [];
  a.xcs = [];
  a.Cp = [];
  a.v0 = [];
  a.pref = [];
  a.V0 = [];
  a.Pref = [];
  a.y = [];
  a.u = [];
  a.ncol = 13;
  a.format = ['%4d %4d ',repmat('%8.4g ',1,7),'%4d %8.4g %8.4g %2u'];
  if Settings.matlab, a = class(a,'SSclass'); end
 case 1
  if isa(varargin{1},'SSclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
