function a = PMclass(varargin)
% constructor of the class PMU
% == PMU ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.dat = [];
  a.vm = [];
  a.thetam = [];
  a.u = [];
  a.ncol = 6;
  a.store = [];
  a.format = ['%4d ',repmat('%8.4g ',1,4),' %2u'];
  if Settings.matlab, a = class(a,'PMclass'); end
 case 1
  if isa(varargin{1},'PMclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
