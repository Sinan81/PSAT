function a = setup(a)

global DAE Settings Varname

% check buses
if isempty(a.con)
  fm_disp(['The data file does not seem to be in a valid ', ...
           'format: no bus found.'])
  Settings.ok = 0;
  a.store = [];
  return
end
a.n = length(a.con(:,1));
a.a = [1:a.n]';
a.v = a.a + a.n;
% set up internal bus numbers for second indexing of buses
a.int(round(a.con(:,1)),1) = a.a;

% check bus voltage rates
if length(a.con(1,:)) < 2
  fm_disp('No voltage rates found in Bus data.',2)
  Settings.ok = 0;
  return
end
idx = find(a.con(:,2) == 0);
if ~isempty(idx)
  fm_disp('Some Bus voltage rate is zero! 1 kV will be used.')
  a.con(idx,2) = 1;
end

% defining bus names
if isfield(Varname,'bus')
  % backward compatibility
  if ~isempty(Varname.bus)
    a.names = Varname.bus;
  end
  Varname = rmfield(Varname,'bus');
end
if length(a.names) ~= a.n
  fm_disp('Bus names does not match bus number.',2)
  a.names = '';
end
if isempty(a.names)
  a.names = fm_strjoin({'Bus '},int2str(a.con(:,1)));
end

DAE.m = 2*a.n;
DAE.y = zeros(DAE.m,1);
DAE.g = zeros(DAE.m,1);
DAE.Gy = sparse(DAE.m,DAE.m);

if length(a.con(1,:)) == 2
  a.con = [a.con, ones(a.n,1)];
end
if length(a.con(1,:)) == 3
  a.con = [a.con, zeros(a.n,1)];
end
if length(a.con(1,:)) == 4
  a.con = [a.con, ones(a.n,1)];
end
if length(a.con(1,:)) == 5
  a.con = [a.con, ones(a.n,1)];
end

% check voltage magnitudes
Vlow  = find(a.con(:,3) < 0.5);
Vhigh = find(a.con(:,3) > 1.5);
if ~isempty(Vlow),
  fm_disp(['Warning: some initial guess voltage magnitudes are too low.'])
end
if ~isempty(Vhigh),
  fm_disp(['Warning: some initial guess voltage magnitudes are too high.'])
end
DAE.y(a.v) = a.con(:,3);

% check voltage phases
aref = min(abs(a.con(:,4)));
alow  = find(a.con(:,4)-aref < -1.5708);
ahigh = find(a.con(:,4)-aref >  1.5708);
if ~isempty(alow),
  fm_disp(['Warning: some initial guess voltage phases are too low.'])
end
if ~isempty(ahigh),
  fm_disp(['Warning: some initial guess voltage phases are too high.'])
end
DAE.y(a.a) = a.con(:,4);

a.Pl = zeros(a.n,1);
a.Ql = zeros(a.n,1);
a.Pg = zeros(a.n,1);
a.Qg = zeros(a.n,1);
a.store = a.con;
