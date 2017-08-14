function a = PLclass(varargin)
% constructor of the Polinomial Load
% == Polinomial Load ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.init = [];
  a.u = [];
  a.store = [];
  a.ncol = 12;
  a.format = ['%4d ',repmat('%8.4g ',1,9),'%2u %2u'];
  if Settings.matlab, a = class(a,'PLclass'); end
 case 1
  if isa(varargin{1},'PLclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
