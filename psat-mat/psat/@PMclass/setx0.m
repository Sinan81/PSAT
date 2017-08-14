function a = setx0(a)

global DAE

if ~a.n, return, end

DAE.x(a.vm) = a.u.*DAE.y(a.vbus);
DAE.x(a.thetam) = a.u.*DAE.y(a.bus);

idx = find(a.con(:,4) == 0);
if ~isempty(idx)
  warn(a,idx, [' Time constant Tv cannot be 0. Tv = 0.05 will be ' ...
               'used.'])
  a.con(idx,4) = 0.05;
end

idx = find(a.con(:,5) == 0);
if ~isempty(idx)
  warn(a,idx, ' Time constant Ta cannot be 0. Ta = 0.05 will be used.')
  a.con(idx,5) = 0.05;
end

a.dat = [1./a.con(:,4), 1./a.con(:,5)];

fm_disp('Initialization of PMUs completed.')


