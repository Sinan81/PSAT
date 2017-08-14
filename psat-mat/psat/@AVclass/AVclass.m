function a = AVclass(varargin)
% constructor of the class Automatic Voltage Regulator
% == AVR ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.syn = [];
  a.bus = [];
  a.vbus = [];
  a.vref = [];
  a.vref0 = [];
  a.vr1  = [];
  a.vr2 = [];
  a.vr3 = [];
  a.vfd = [];
  a.vm = [];
  a.vf = [];
  a.u = [];
  a.store = [];
  a.ncol = 14;
  a.format = ['%4d %4d ',repmat('%8.4g ',1,11),'%2u'];
  if Settings.matlab, a = class(a,'AVclass'); end
 case 1
  if isa(varargin{1},'AVclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
