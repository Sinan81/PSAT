function a = add(a,data,varargin)

global Bus

newbus = getint(Bus,data(1));
idx = findbus(a,newbus);
if isempty(idx)
  a.n = a.n + 1;
  if length(data) < a.ncol
    data(1,a.ncol) = 1;
  end
  switch nargin
   case 2
    a.gen = [a.gen; 0];
   otherwise
    a.gen = [a.gen; varargin{1}];
  end
  a.con = [a.con; data];
  a.bus = [a.bus; newbus];
  a.vbus = a.bus + Bus.n;
  a.shunt = [a.shunt; 0];
  a.vmax = [a.vmax; 0];
  a.vmin = [a.vmin; 0];
  a.u = data(:,a.ncol);
  a.P0 = [a.P0;a.u(end)*data(4)];
  a.Q0 = [a.Q0;a.u(end)*data(5)];
else
  a = pqsum(a,idx,data(4),data(5));
  a.con(idx,6) = min(a.con(idx,6),data(6));
  a.con(idx,7) = max(a.con(idx,7),data(7));
end

