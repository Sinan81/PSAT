function bdmatrix(a)

global LA DAE 

LA.b_hvdc = [];  
LA.d_hvdc = [];  

if ~a.n
  fm_disp('* * * No HVDC device found')
  return
end

iyr = 1:2:2*a.n;
iyi = 2:2:2*a.n;

uI = a.u.*a.dat(:,9);
uP = a.u.*a.dat(:,10);
uV = a.u.*a.dat(:,11);

Vrdc = a.u.*DAE.y(a.Vrdc);
Vidc = a.u.*DAE.y(a.Vidc);

Fu = sparse(DAE.n,2*a.n);
Gu = sparse(a.yr,iyr,uI+uV+uP./(~a.u+Vrdc),DAE.m,2*a.n) + ...
     sparse(a.yi,iyi,uI+uV+uP./(~a.u+Vidc),DAE.m,2*a.n);

% B & D matrix for HVDC references
LA.d_hvdc = -full(DAE.Gy\Gu);
LA.b_hvdc = full(Fu + DAE.Fy*LA.d_hvdc);  

