function a = add(a,data)

global Bus

newbus = Bus.int(round(data(1)));
idx = findbus(a,newbus);

if isempty(idx)
  a.n = a.n + 1;
  a.con = [a.con; data];
  [a.bus,a.vbus] = getbus(Bus,a.con(:,1));
  a.pg = data(10);
  a.qmax = [a.qmax; 1];
  a.qmin = [a.qmin; 1];
  a.qg = [a.qg; 0];
  a.dq = [a.dq; 0];
  a.u = data(a.ncol);
else
  a.con(idx,6) = a.con(idx,8)+data(8);
  a.con(idx,7) = a.con(idx,9)+data(9);
  a.con(idx,8) = min(a.con(idx,8),data(8));
  a.con(idx,9) = max(a.con(idx,9),data(9));
  a.con(idx,10) = a.con(idx,10)+data(10);
  a.con(idx,11) = max(a.con(idx,11),data(11));
  a.dq(idx) = 0;
  a.qg(idx) = 0;
  a.pg = a.pg+data(10);
  a.qmax(idx) = 1;
  a.qmin(idx) = 1;
end
