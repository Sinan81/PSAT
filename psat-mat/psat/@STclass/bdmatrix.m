function bdmatrix(a)

global LA DAE 

LA.b_statcom = [];  
LA.d_statcom = [];  

if ~a.n
  fm_disp('* * * No Statcom device found')
  return
end

Fu = sparse(DAE.n,a.n);
Gu = sparse(a.vref,1:a.n,a.u,DAE.m,a.n);

% B & D matrix for reference voltage
LA.d_statcom = -full(DAE.Gy\Gu);
LA.b_statcom = full(Fu + DAE.Fy*LA.d_statcom);  

