function a = dynidx(a)

global DAE

if ~a.n, return, end

a.Idc = zeros(a.n,1);
a.xr = zeros(a.n,1);
a.xi = zeros(a.n,1);

a.cosa = zeros(a.n,1);  
a.cosg = zeros(a.n,1); 
a.phir = zeros(a.n,1);  
a.phii = zeros(a.n,1);
a.Vrdc = zeros(a.n,1);
a.Vidc = zeros(a.n,1);
a.yr = zeros(a.n,1);   
a.yi = zeros(a.n,1);

for i = 1:a.n

  a.Idc(i) = DAE.n + 1;
  a.xr(i) = DAE.n + 2;
  a.xi(i) = DAE.n + 3;
  
  DAE.n = DAE.n + 3;

  a.cosa(i) = DAE.m + 1;  
  a.cosg(i) = DAE.m + 2; 
  a.phir(i) = DAE.m + 3;  
  a.phii(i) = DAE.m + 4;
  a.Vrdc(i) = DAE.m + 5;
  a.Vidc(i) = DAE.m + 6;
  a.yr(i) = DAE.m + 7;   
  a.yi(i) = DAE.m + 8; 
  
  DAE.m = DAE.m + 8;
  
end

% extend the vector of algebraic variables 
DAE.y = [DAE.y; zeros(8*a.n,1)];
