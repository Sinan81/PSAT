function a = SUclass(varargin)
% constructor of the class Supply
% == Supply ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.store = [];
  a.ncol = 20;
  a.u = [];
  a.format = ['%4d ',repmat('%8.4g ',1,11),'%2u ', repmat('%8.4g ',1,6),'%2u'];
  if Settings.matlab, a = class(a,'SUclass'); end
 case 1
  if isa(varargin{1},'SUclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
