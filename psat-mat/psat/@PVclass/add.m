function a = add(a,data)

global Bus

newbus = getint(Bus,data(1));
idx = findbus(a,newbus);

if isempty(idx)
  a.n = a.n + 1;
  if length(data) < a.ncol
    data(1,a.ncol) = 1;
  end
  a.con = [a.con; data];
  a.bus = [a.bus; newbus];
  a.vbus = a.bus + Bus.n;
  a.u = data(:,a.ncol);
  a.pq = [a.pq; 0];
  a.qg = [a.qg; 0];
  a.qmax = [a.qmax; 1];
  a.qmin = [a.qmin; 1];
else
  a.con(idx,4) = a.con(idx,4)+data(4);
  a.con(idx,6) = a.con(idx,8)+data(8);
  a.con(idx,7) = a.con(idx,9)+data(9);
  a.con(idx,8) = min(a.con(idx,8),data(8));
  a.con(idx,9) = max(a.con(idx,9),data(9));
  a.con(idx,10) = max(a.con(idx,10),data(10));
  a.pq(idx) = 0;
  a.qg(idx) = 0;
  a.qmax(idx) = 1;
  a.qmin(idx) = 1;
end
