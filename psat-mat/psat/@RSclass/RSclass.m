function a = RSclass(varargin)
% constructor of the class Rsrv
% == Generator Reserve ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.u = [];
  a.Pr = [];
  a.store = [];
  a.ncol = 6;
  a.format = ['%4d ',repmat('%8.4g ',1,4),'%2u'];
  if Settings.matlab, a = class(a,'RSclass'); end
 case 1
  if isa(varargin{1},'RSclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
