function a = HVclass(varargin)
% constructor of the class HVDC
% == HVDC ==

global Settings

switch nargin
 case 0
  a.con = [];
  a.n = 0;
  a.bus1 = [];
  a.bus2 = [];
  a.v1 = [];
  a.v2 = [];
  a.dat = [];
  a.Idc = [];
  a.xr = [];
  a.xi = [];
  a.cosa = [];  
  a.cosg = []; 
  a.phir = [];  
  a.phii = [];
  a.Vrdc = [];
  a.Vidc = [];
  a.yr = [];   
  a.yi = []; 
  a.store = [];
  a.u = [];
  a.ncol = 29;
  a.format = ['%4d %4d ',repmat('%8.4g ',1,26),'%2u'];
  if Settings.matlab, a = class(a,'HVclass'); end
 case 1
  if isa(varargin{1},'HVclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
