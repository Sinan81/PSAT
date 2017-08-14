function a = FPVclass(varargin)
% constructor of the class Flat Pv
% == Photovoltaic Flat Module ==

global Settings

switch nargin
 case 0

  a.con = [];
  a.dat = [];
  a.n = 0;
  a.conv = [];

  a.Tc = []; % indexes of the state variable Tc
  
  a.Ig = []; % indexes of alg. variable Ig (dc current)
  a.I0 = []; % indexes of alg. variable I0 (dc current)
  a.IL = []; % indexes of alg. variable IL (dc current)
  a.Vg = []; % indexes of alg. varibale Vg (dc voltage)
  a.Eg = []; % indexes of alg. varibale Eg (energy band gap)
  
  a.q = 1.6e-19;
  a.K = 1.38e-23;

  a.u = [];
  a.store = [];
  a.ncol = 20;
  a.format = ['%4d ', repmat('%8.4g ',1,18), '%2u'];
  if Settings.matlab, a = class(a,'FPVclass'); end
 case 1
  if isa(varargin{1},'FPVclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
