function a = LTclass(varargin)
% constructor of the class Load Tap Changer
% == Ltc ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus1 = [];
  a.bus2 = [];
  a.v1 = [];
  a.v2 = [];
  a.vr = [];
  a.mc = [];
  a.md = [];
  a.mold = [];
  a.store = [];
  a.delay = [];
  a.u = [];
  a.ncol = 18;
  a.format = ['%4d %4d ',repmat('%8.4g ',1,13),'%4d %8.4g %2u'];
  if Settings.matlab, a = class(a,'LTclass'); end
 case 1
  if isa(varargin{1},'LTclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
