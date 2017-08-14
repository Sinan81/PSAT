function a = SWclass(varargin)
% constructor of the class SW
% == Swing generator ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.pg = [];
  a.store = [];
  a.qg = [];
  a.dq = [];
  a.qmax = [];
  a.qmin = [];
  a.u = [];
  a.refbus = [];
  a.ncol = 13;
  a.format = ['%4d ',repmat('%8.4g ',1,10),'%2u %2u'];
  if Settings.matlab, a = class(a,'SWclass'); end
 case 1
  if isa(varargin{1},'SWclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
