function a = DDclass(varargin)
% constructor of the class Direct Drive Synchronous Generator
% == DDSG ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.wind = [];
  a.dat = [];
  a.omega_m = [];
  a.theta_p = [];
  a.pwa = [];
  a.ids = [];
  a.iqs = [];
  a.idc = [];
  a.iqc = [];
  a.store = [];
  a.u = [];
  a.ncol = 26;
  a.format = ['%4d %4d ',repmat('%8.4g ',1,22),'%2u %2u'];
  if Settings.matlab, a = class(a,'DDclass'); end
 case 1
  if isa(varargin{1},'DDclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
