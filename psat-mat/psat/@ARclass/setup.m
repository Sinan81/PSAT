function a = setup(a)

global Bus Settings

switch a.type
 case 'area'
  str = 'Area ';
  msg = 'Area names does not match area number.';
  area_buses = getarea(Bus,0,0);
 case 'region'
  str = 'Region ';
  msg = 'Region names does not match region number.';
  area_buses = getregion(Bus,0,0);
end
areas = unique(area_buses);
narea = length(areas);
ndiff = 0;
newarea = [];
a.store = [];

if ~isempty(a.con)
  a.n = length(a.con(:,1));
  ncol = length(a.con(1,:));
  if ncol < a.ncol
    a.con = [a.con, zeros(a.n,a.ncol-ncol)];
  end
  a.slack = zeros(a.n,1);
  sdx = find(a.con(:,2));
  if ~isempty(sdx)
    a.slack(sdx) = getint(Bus,a.con(sdx,2));
  end
  % check consistency with Bus data
  if a.n ~= narea
    areaid = a.con(:,1);
    newarea = setdiff(areas,areaid);
    if ~isempty(newarea)
      ndiff = length(newarea);
      n = ndiff;
      a.n = a.n + n;
      a.con = [a.con; [newarea,zeros(n,1),100*ones(n,1),zeros(n,5)]];
      a.slack = [a.slack; zeros(n,1)];
    end
  end
else
  % define areas based on Bus data
  ndiff = narea;
  newarea = areas;
  a.n = narea;
  a.con = [areas,zeros(a.n,1),100*ones(a.n,1),zeros(a.n,5)];
  a.slack = zeros(a.n,1);
end

return
% set up internal area numbers for second indexing of areas
a.int(round(a.con(:,1)),1) = [1:a.n]';

% define bus groups
a.bus = cell(a.n,1);
for i = 1:a.n
  area_i = find(area_buses == a.con(i,1));
  if ~isempty(area_i)
    bus_idx = getidx(Bus,area_i);
    a.bus{i} = getint(Bus,bus_idx)';
  end
end

% define area names
nnames = length(a.names);
if nnames > 0
  if ndiff
    names = fm_strjoin({str},int2str(newarea));
    a.names = [a.names; names];
  elseif nnames ~= a.n
    fm_disp(msg,2)
    a.names = '';
  end
end
if isempty(a.names)
  a.names = fm_strjoin({str},int2str(a.con(:,1)));
end

a.store = a.con;
