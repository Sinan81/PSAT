function a = LNclass(varargin)
% constructor of the class LINE
% == Transmission Lines & Fixed Tap Transformers ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.fr = [];
  a.to = [];
  a.vfr = [];
  a.vto = [];
  a.Y = [];
  a.Bp = [];
  a.Bpp = [];
  a.p = [];
  a.q = [];
  a.ncol = 16;
  a.u = [];
  a.nu = 16;
  a.no_build_y = 0;
  a.format = ['%4d %4d ',repmat('%8.4g ',1,13),'%2u'];
  a.store = [];
  if Settings.matlab, a = class(a,'LNclass'); end
 case 1
  if isa(varargin{1},'LNclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
