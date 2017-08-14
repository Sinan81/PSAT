function a = remove(a,idx,flag)

if ~a.n, return, end
if isempty(idx), return, end
switch flag
 case 'zero'
  ii = find(a.con(idx,4) == 0 & a.con(idx,5) == 0);
  k = idx(ii);
 case 'force'
  k = idx;
 case 'onlyload'
  k = find(a.gen == 0);
 case 'all'
  k = [1:a.n];
end
a.con(k,:) = [];
a.bus(k) = [];
a.vbus(k) = [];
a.gen(k) = [];
a.shunt(k) = [];
a.n = a.n - length(k);
a.u(k) = [];
a.P0(k) = [];
a.Q0(k) = [];
a.vmax(k) = [];
a.vmin(k) = [];
