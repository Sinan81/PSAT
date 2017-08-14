function a = DMclass(varargin)
% constructor of the class Demand
% == Demand load ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.u = [];
  a.store = [];
  a.ncol = 18;
  a.format = ['%4d ',repmat('%8.4g ',1,12),'%2u %8.4g %8.4g %8.4g %2u'];
  if Settings.matlab, a = class(a,'DMclass'); end
 case 1
  if isa(varargin{1},'DMclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
