function B = bsvc(a)

global DAE

B = zeros(a.n,1); 

if a.ty1
  B(a.ty1) = DAE.x(a.bcv);
end

if a.ty2
  xl = a.con(a.ty2,15);
  xc = a.con(a.ty2,16);
  B(a.ty2) = (2*DAE.x(a.alpha) - sin(2*DAE.x(a.alpha)) ...
              - pi*(2-xl./xc))./(pi*xl);
end
