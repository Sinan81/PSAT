function a = TGclass(varargin)
% constructor of the class Turbine Governor
% == Turbine Governor ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.syn = [];
  a.pm = [];
  a.wref = [];
  a.store = [];
  a.dat1 = [];
  a.dat2 = [];
  a.dat3 = [];
  a.dat4 = [];
  a.dat5 = [];
  a.dat6 = [];
  a.tg = [];
  a.tg1 = [];
  a.tg2 = [];
  a.tg3 = [];
  a.tg4 = [];
  a.tg5 = [];
  a.ty1 = [];
  a.ty2 = [];
  a.ty3 = [];
  a.ty4 = [];
  a.ty5 = [];
  a.ty6 = [];
  a.u = [];
  a.ncol = 20;
  a.format = ['%4d %4d ',repmat('%8.4g ',1,17),'%2d'];
  if Settings.matlab, a = class(a,'TGclass'); end
 case 1
  if isa(varargin{1},'TGclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
