function bdmatrix(a)

global LA DAE 

LA.b_svc = [];  
LA.d_svc = [];  

if ~a.n
  fm_disp('* * * No SVC device found')
  return
end

Fu = sparse(DAE.n,a.n);
Gu = sparse(a.vref,1:a.n,a.u,DAE.m,a.n);

% B & D matrix for reference voltage
LA.d_svc = -full(DAE.Gy\Gu);
LA.b_svc = full(Fu + DAE.Fy*LA.d_svc);  

