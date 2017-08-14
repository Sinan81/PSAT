function a = PHclass(varargin)
% constructor of the class Phase Shifter
% == Phs ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus1 = [];
  a.bus2 = [];
  a.v1 = [];
  a.v2 = [];
  a.alpha = [];
  a.Pm = [];
  a.store = [];
  a.u = [];
  a.ncol = 16;
  a.format = ['%4d %4d ',repmat('%8.4g ',1,13),'%2u'];
  if Settings.matlab, a = class(a,'PHclass'); end
 case 1
  if isa(varargin{1},'PHclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
