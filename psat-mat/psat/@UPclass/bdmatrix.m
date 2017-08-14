function bdmatrix(a)

global LA DAE 

LA.b_upfc = [];  
LA.d_upfc = [];  

if ~a.n
  fm_disp('* * * No UPFC device found')
  return
end

ivp = 1:3:3*a.n;
ivq = 2:3:3*a.n;
ivr = 3:3:3*a.n;

ty2 = find(a.con(:,2) == 1); % constant voltage control

Fu = sparse(DAE.n,3*a.n);
Gu = sparse(a.vp0,ivp,a.u,DAE.m,3*a.n) + ...
     sparse(a.vq0(ty2),ivq(ty2),a.u(ty2),DAE.m,3*a.n) + ...
     sparse(a.vref,ivr,a.u,DAE.m,3*a.n);

% B & D matrix for UPFC references
LA.d_upfc = -full(DAE.Gy\Gu);
LA.b_upfc = full(Fu + DAE.Fy*LA.d_upfc);  

