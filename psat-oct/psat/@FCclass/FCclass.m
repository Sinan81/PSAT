function a = FCclass(varargin)
% constructor of the Solid Oxide Fuel Cell
% == Sofc ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.Ik = [];
  a.Vk = [];
  a.pH2 = [];
  a.pH2O = [];
  a.pO2 = [];
  a.qH2 = [];
  a.m = [];
  a.u = [];
  a.ncol = 31;
  a.format = ['%4d ',repmat('%8.4g ',1,29),'%2u'];
  a.store = [];
  if Settings.matlab, a = class(a,'FCclass'); end
 case 1
  if isa(varargin{1},'FCclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
