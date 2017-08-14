function a = SYclass(varargin)
% constructor of the class Syn
% == SYNCHRONOUS MACHINES ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.Id = [];
  a.Iq = [];
  a.J11 = [];
  a.J12 = [];
  a.J21 = [];
  a.J22 = [];
  a.delta = [];
  a.omega = [];
  a.e1q = [];
  a.e1d = [];
  a.e2q = [];
  a.e2d = [];
  a.psiq = [];
  a.psid = [];
  a.pm = [];
  a.vf = [];
  a.p = [];
  a.q = [];
  a.pm0 = [];
  a.vf0 = [];
  a.Pg0 = [];
  a.c1 = [];
  a.c2 = [];
  a.c3 = [];
  a.u = [];
  a.store = [];
  a.ncol = 28;
  a.format = ['%4d %8.4g %8.4g %8.4g %4d ',repmat('%8.4g ',1,21),'%4d %2u'];
  if Settings.matlab, a = class(a,'SYclass'); end
 case 1
  if isa(varargin{1},'SYclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
