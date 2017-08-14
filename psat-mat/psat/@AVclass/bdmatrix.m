function bdmatrix(a)

global LA DAE

LA.b_avr = [];  
LA.d_avr = [];  

if ~a.n
  fm_disp('* * * No automatic voltage control found')
  return
end

Fu = sparse(DAE.n,a.n);
Gu = sparse(a.vref,1:a.n,a.u,DAE.m,a.n);

% B & D matrix for Vref0
LA.d_avr = -full(DAE.Gy\Gu);
LA.b_avr = full(Fu + DAE.Fy*LA.d_avr);  
