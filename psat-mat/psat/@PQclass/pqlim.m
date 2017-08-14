function [a, check] = pqlim(a,vlim,sp,lambda,one)  

global DAE

check = 0;

if ~vlim, return, end
if ~a.n, return, end

vmax_idx = find(DAE.y(a.vbus) > a.con(:,6) & a.vmax & a.u);
vmin_idx = find(DAE.y(a.vbus) < a.con(:,7) & a.vmin & a.u);
if ~isempty(vmin_idx)
  a.vmin(vmin_idx(1)) = 0;
  fm_disp([sp,'PQ load at bus #',fvar(a.bus(vmin_idx(1)),4), ...
           ' reached V_min at lambda = ',fvar(lambda-one,9)])
  check = 1;
  return
end
if ~isempty(vmax_idx)
  a.vmax(vmax_idx(1)) = 0;
  fm_disp([sp,'PQ load at bus #',fvar(a.bus(vmax_idx(1)),4), ...
           ' reached V_max at lambda = ',fvar(lambda-one,9)])
  check = 1;
end
