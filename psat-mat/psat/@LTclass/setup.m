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

% fix data for backward compatibility
if length(a.con(1,:)) < 17
  a.con = [a.con, 0.5*ones(a.n, 1)];
  a.u = ones(a.n,1);
elseif length(a.con(1,:)) == 17
  a.u = a.con(:,17);
  a.con(:,17) = 0.5*ones(a.n, 1);
else
  a.u = a.con(:,a.ncol);
end

a.delay = Settings.t0*ones(a.n,1);
a.mold = ones(a.n,1);
a.store = a.con;

% fix remote control bus number
a.vr = a.v2;
idx = find(a.con(:,16) == 3);
if ~isempty(idx)
  a.vr(idx) = getvint(Bus,a.con(idx,15));
end

% fix nominal tap ratio
idx = find(a.con(:,6) == 0);
if ~isempty(idx)
  a.con(idx,6) = 1;
end

Settings.nseries = Settings.nseries + a.n;
