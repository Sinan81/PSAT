function a = SPVclass(varargin)
% constructor of the class Solar Photo-Voltaic Generator
% == SPVG ==
% Constant P & Constant V
% Developed by Behnam Tamimi <btamimi@ieee.org>
% December, 2009

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus = [];
  a.vbus = [];
  a.dat = [];
  a.btx1 = [];
  a.id = [];
  a.iq = [];
  a.vref = [];
  a.store = [];
  a.u = [];
  a.ncol = 8;
  a.format = ['%4d ',repmat('%8.4g ',1,6),'%2u'];
  if Settings.matlab, a = class(a,'SPVclass'); end
 case 1
  if isa(varargin{1},'SPVclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
