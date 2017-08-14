function a = setx0(a)

global DAE

if ~a.n, return, end

Kw = a.con(:,7);
Tw = a.con(:,8);
T2 = a.con(:,10);
T4 = a.con(:,12);
Tr = a.con(:,13);

idx = find(Kw == 0);
if idx,
  a.con(idx,7) = 1;
  warn(a,idx,' Kw cannot be zero. Default value Kw = 1 will be used.')
end
idx = find(Tw == 0);
if idx,
  a.con(idx,8) = 1;
  warn(a,idx,' Tw cannot be zero. Default value Tw = 1 will be used.')
end
idx = find(T2 == 0);
if idx,
  a.con(idx,10) = 0.01;
  warn(a,idx,' T2 cannot be zero. Default value T2 = 0.01 will be used.')
end
idx = find(T4 == 0);
if idx,
  a.con(idx,12) = 0.01;
  warn(a,idx,' T4 cannot be zero. Default value T4 = 0.01 will be used.')
end
idx = find(Tr == 0);
if idx,
  a.con(idx,13) = 0.001;
  warn(a,idx,' Tr cannot be zero. Default value Tr = 0.001 will be used.')
end

DAE.x(a.v1) = a.u.*vsi(a).*Kw;
DAE.x(a.v2) = 0;
DAE.x(a.v3) = 0;
DAE.y(a.Vs) = 0;

fm_disp('Initialization of Power Oscillation Damper completed.')
