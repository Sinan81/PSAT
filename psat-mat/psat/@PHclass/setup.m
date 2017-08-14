function a = setup(a,varargin)

global Settings

switch nargin
 case 2
  Bus = varargin{1};
 otherwise
  global Bus
end

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
[a.bus1,a.v1] = getbus(Bus,a.con(:,1));
[a.bus2,a.v2] = getbus(Bus,a.con(:,2));

if length(a.con(1,:)) < 15
  a.con = [a.con; ones(a.n,1)];
end

idx = find(a.con(:,15)==0);
if ~isempty(idx)
  a.con(idx,15) = 1;
end

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end

a.store = a.con;

Settings.nseries = Settings.nseries + a.n;
