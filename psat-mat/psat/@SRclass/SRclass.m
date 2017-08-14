function a = SRclass(varargin)
% constructor of the Subsynchronous Resonance Model
% == SSR ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.Id = [];
  a.Iq = [];
  a.If = [];
  a.Edc = [];
  a.Eqc = [];
  a.Tm = [];
  a.Efd = [];
  a.delta_HP = [];
  a.omega_HP = [];
  a.delta_IP = [];
  a.omega_IP = [];
  a.delta_LP = [];
  a.omega_LP = [];
  a.delta = [];
  a.omega = [];
  a.delta_EX = [];
  a.omega_EX = [];
  a.u = [];
  a.ncol = 28;
  a.format = ['%4d ',repmat('%8.4g ',1,26),'%2u'];
  a.store = [];
  if Settings.matlab, a = class(a,'SRclass'); end
 case 1
  if isa(varargin{1},'SRclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
