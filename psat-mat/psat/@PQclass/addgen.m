function a = addgen(a,b,varargin)

if ~b.n, return, end

global Settings

switch nargin
 case 3
  Bus = varargin{1};
 otherwise
  global Bus
end

% set generated powers as negative loads
b.gen = ones(b.n,1);
b.P0 = -b.P0;
b.Q0 = -b.Q0;
b.con(:,4) = b.P0;
b.con(:,5) = b.Q0;

% append PQ generators to PQ loads
a.con = [a.con; b.con];
a.n = a.n + b.n;
a.bus = [a.bus; b.bus];
a.vbus = a.bus + Bus.n;
a.gen = [a.gen; b.gen];
a.u = [a.u; b.u];
a.shunt = [a.shunt; b.shunt];
a.P0 = [a.P0; b.P0];
a.Q0 = [a.Q0; b.Q0];
a.vmax = [a.vmax; b.vmax];
a.vmin = [a.vmin; b.vmin];

[u,h,k] = unique(a.bus);
if length(k) > length(h)
  fm_disp(['Error: it is not allowed to connect a PQ load and a PQ ', ...
           'generator to the same bus.'],2)
  Settings.ok = 0;
  return
end
