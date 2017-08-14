function bdmatrix(a)

global LA DAE 

LA.b_tg = [];  
LA.d_tg = [];  

if ~a.n
  fm_disp('* * * No turbine governor found')
  return
end

Fu = sparse(DAE.n,a.n);
Gu = sparse(a.wref,1:a.n,a.u,DAE.m,a.n);

% B & D matrix for reference speed
LA.d_tg = -full(DAE.Gy\Gu);
LA.b_tg = full(Fu + DAE.Fy*LA.d_tg);  
