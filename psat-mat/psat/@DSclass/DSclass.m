function a = DSclass(varargin)
% constructor of the Dynamic Shaft Model
% == Mass ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.syn = [];
  a.delta_HP = [];
  a.omega_HP = [];
  a.delta_IP = [];
  a.omega_IP = [];
  a.delta_LP = [];
  a.omega_LP = [];
  a.delta_EX = [];
  a.omega_EX = [];
  a.omega = [];
  a.delta = [];
  a.pm = [];
  a.u = [];
  a.ncol = 18;
  a.format = ['%4d ',repmat('%8.4g ',1,16),' %2d'];
  a.store = [];
  if Settings.matlab, a = class(a,'DSclass'); end
 case 1
  if isa(varargin{1},'DSclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
