function a = WTFRclass(varargin)
% == Frequency control for wind generators ==

global Settings

switch nargin
 case 0
% A continuaci´on tenemos que definir todas las entradas al sistema

a.con = [];   % DATA - para definir las matrices de datos que se definen en PSAT.
a.n = 0;      % NUMBER OF DEVICES.
a.gen = [];   % INDICE DE LOS GENERADORES NO CONVENCIONALES.
a.freq = [];
a.dat = [];   % Internal data. 

% ahora empezamos a introducir las variables externas a nuestro sitema (regulador).

a.we = [];  %Indice de estado de la variable velocidad omega_e.
a.Df = [];  %Indice de estado de la variable velocidad delta_f.

% YA ESTAN DEFINIDAS LA EXTERNAS Y AHORA LAS INTERNAS.

a.Dfm = [];     %Indice de estado de la variable delta_fm.
a.x  =  [];     %Indice de estado de la variable x.
a.csi = [];     %Indice de estado de la variable csi.
a.pfw = [];     %Indice de estado de la variable p_fw.
a.pwa = [];     %Indice de estado de la variable p_w*.
a.pf1 = [];     %Indice de estado de la variable p'_f.
a.pout = [];    %Indice de estado de la variable p_out.
a.store = [];
a.u = [];
a.ncol = 15;
a.format = ['%4d %4d ',repmat('%8.4g ',1,9),'%2d'];
if Settings.matlab, a = class(a,'WTFRclass'); end
 case 1
  if isa(varargin{1},'WTFRclass')
    a = varargin{1};
  else
    error('Wrong argument type')
  end
 otherwise
  error('Wrong Number of input arguments')
end
