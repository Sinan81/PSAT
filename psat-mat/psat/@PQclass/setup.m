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

a.bus = getint(Bus,a.con(:,1));
[b,h,k] = unique(a.bus);
if length(k) > length(h)

  if length(a.con(1,:)) < a.ncol
    u = ones(length(a.con(:,1)),1);
  else
    u = a.con(:,a.ncol);
  end
  
  fm_disp('Warning: More than one PQ load connected to the same bus.')

  con = zeros(length(b),a.ncol);
  con(:,1) = b;
  con(:,2) = 100;
  con(:,6) = 1.2;
  con(:,7) = 0.8;
  Vb = getkv(Bus,a.bus,1);
  
  for i = 1:length(k)
    vb = a.con(i,3)/Vb(i);
    con(k(i),3) = Vb(i);
    con(k(i),4) = con(k(i),4) + u(i)*a.con(i,4)*a.con(i,2)/100;
    con(k(i),5) = con(k(i),5) + u(i)*a.con(i,5)*a.con(i,2)/100;
    if a.con(i,6), con(k(i),6) = min(con(k(i),6),a.con(i,6)*vb); end
    if a.con(i,7), con(k(i),7) = max(con(k(i),7),a.con(i,7)*vb); end
    con(k(i),8) = a.con(i,8);
    if u(i), con(k(i),a.ncol) = 1; end
  end
  
  a.con = con;
  a.bus = b;

end

a.vbus = a.bus + Bus.n;
a.n = length(a.con(:,1));
a.gen = zeros(a.n,1); 
a.shunt = zeros(a.n,1); 

switch length(a.con(1,:))
 case a.ncol
  % all OK!
 case 5
  a.con = [a.con,1.2*ones(a.n,1),0.8*ones(a.n,1), ...
           zeros(a.n,1),ones(a.n,1)];
 case 7
  a.con = [a.con,zeros(a.n,1),ones(a.n,1)];
 case 8
  a.con = [a.con,ones(a.n,1)];
 otherwise
  a.con(:,6) = 1.2;
  a.con(:,7) = 0.8;
  a.con(:,8) = 0;
  fm_disp('Error: PQ data format is not consistent.',2)
end

if length(a.con(1,:)) < a.ncol
  a.u = ones(a.n,1);
else
  a.u = a.con(:,a.ncol);
end

idx = find(a.con(:,6) <= 0);
if ~isempty(idx), a.con(idx,6) = 1.2; end
idx = find(a.con(:,7) <= 0);
if ~isempty(idx), a.con(idx,7) = 0.8; end

a.P0 = a.u.*a.con(:,4);
a.Q0 = a.u.*a.con(:,5);
a.vmax = ones(a.n,1);
a.vmin = ones(a.n,1);
a.store = a.con;
