function a = setup(a,varargin)

global DAE Settings

switch nargin
 case 3
  Bus = varargin{1};
  PV = varargin{2};
 otherwise
  global Bus
  global PV
end

if isempty(a.con)
  a.store = [];
  fm_disp('Error: No slack bus found.',2)
  Settings.ok = 0;
  return
end

a.n = length(a.con(:,1));
[a.bus,a.vbus] = getbus(Bus,a.con(:,1));

b = unique(a.bus);
if a.n > length(b)
  fm_disp(['Error: More than one slack generator ', ...
           'connected to the same bus.'],2)
  Settings.ok = 0;
  return
end

switch length(a.con(1,:))
 case 5
  a.con = [a.con, 999*ones(a.n,1), -999*ones(a.n,1), ...
           1.1*ones(a.n,1), 0.9*ones(a.n,1), ...
           zeros(a.n,1), ones(a.n,3)];
 case 6
  a.con = [a.con, -999*ones(a.n,1), ...
           1.1*ones(a.n,1), 0.9*ones(a.n,1), ...
           zeros(a.n,1), ones(a.n,3)];
 case 7
  a.con = [a.con, 1.1*ones(a.n,1), 0.9*ones(a.n,1), ...
           zeros(a.n,1), ones(a.n,3)];
 case 8
  a.con = [a.con, 0.9*ones(a.n,1), ...
           zeros(a.n,1), ones(a.n,3)];
 case 9
  a.con = [a.con, zeros(a.n,1), ones(a.n,3)];
 case 10
  a.con = [a.con, ones(a.n,3)];
 case 11
  a.con = [a.con, ones(a.n,2)];
 case 12
  a.con = [a.con, ones(a.n,1)];
end

z = a.con(:,12);
a.u = a.con(:,a.ncol);

% at least one angle must be the reference
if sum(z) == 0
  a.con(1,12) = 1;
  z(1) = 1;
end
  
% at least one bus must be the slack
if sum(a.u) == 0
  a.u(find(z)) = 1;
  a.con(find(z),a.ncol) = 1;
end

DAE.y(a.vbus) = a.con(:,4);
if ~sum(DAE.y(Bus.a)) && a.n == 1
  DAE.y(Bus.a) = a.con(1,5);
else
  DAE.y(a.bus) = a.con(:,5);
end

% fix reactive power limits
idx = find(a.con(:,6) == 0 & a.con(:,7) == 0);
if ~isempty(idx)
  a.con(:,6) =  99*Settings.mva;
  a.con(:,7) = -99*Settings.mva;
end
 
% checking the consistency of distributed slack bus
idxpv = pvgamma(PV,'sum');
idxsw = swgamma(a,'sum');
if ~idxpv && ~idxsw, a = setgamma(a); end

a.refbus = a.bus(find(z & a.u));
a.pg = a.con(:,10);
a.dq = zeros(a.n,1);
a.qg = zeros(a.n,1);
a.qmax = ones(a.n,1);
a.qmin = ones(a.n,1);
a.store = a.con;
