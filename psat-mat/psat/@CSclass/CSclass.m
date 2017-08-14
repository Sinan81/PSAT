function a = CSclass(varargin)
% constructor of the class Constant Speed Wind Turbine
% == CSWT ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.wind = [];
  a.dat = [];
  a.omega_t = [];
  a.omega_m = [];
  a.gamma = [];
  a.e1r = [];
  a.e1m = [];
  a.store = [];
  a.u = [];
  a.ncol = 19;
  a.format = ['%4d %4d ',repmat('%8.4g ',1,15),'%2u %2u'];
  if Settings.matlab, a = class(a,'CSclass'); end
 case 1
  if isa(varargin{1},'CSclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
