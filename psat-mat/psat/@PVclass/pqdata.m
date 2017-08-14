function data = pqdata(a,idx,qlim,sp,lambda,one,nosup)

if ~a.n, return, end

idx = idx(1);
data = [a.con(idx,[1 2 3 4 6 8 9]),0,1];
if nosup
  data(1,4) = 0;  
else
  data(1,4) = -a.u(idx)*a.con(idx,4);  
end

switch qlim
 case 'qmax'
  data(1,5) = -a.u(idx)*a.con(idx,6);  
  fm_disp([sp,'PV gen. at bus #', fvar(a.bus(idx),4), ...
           ' reached Q_max at lambda = ',fvar(lambda-one,9)])
 case 'qmin'
  data(1,5) = -a.u(idx)*a.con(idx,7);  
  fm_disp([sp,'PV gen. at bus #', fvar(a.bus(idx),4), ...
           ' reached Q_min at lambda = ',fvar(lambda-one,9)])
 case 'qmaxl'
  data(1,5) = -a.u(idx)*a.con(idx,6);  
 case 'qminl'
  data(1,5) = -a.u(idx)*a.con(idx,7);  
end
