function fm_call(flag)


%FM_CALL calls component equations
%
%FM_CALL(CASE)
%  CASE '1'  algebraic equations
%  CASE 'pq' load algebraic equations
%  CASE '3'  differential equations
%  CASE '1r' algebraic equations for Rosenbrock method
%  CASE '4'  state Jacobians
%  CASE '0'  initialization
%  CASE 'l'  full set of equations and Jacobians
%  CASE 'kg' as "L" option but for distributed slack bus
%  CASE 'n'  algebraic equations and Jacobians
%  CASE 'i'  set initial point
%  CASE '5'  non-windup limits
%
%see also FM_WCALL

fm_var

switch flag


 case 'gen'

  Line = gcall(Line);
  gcall(PQ)

 case 'load'

  gcall(PQ)
  gisland(Bus)

 case 'gen0'

  Line = gcall(Line);
  gcall(PQ)

 case 'load0'

  gcall(PQ)
  gisland(Bus)

 case '3'

  
 case '1r'

  Line = gcall(Line);
  gcall(PQ)
  PV = gcall(PV);
  SW = gcall(SW);
  gisland(Bus)

 case 'series'

  Line = gcall(Line);
  gisland(Bus)

 case '4'

  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  
 case '0'

  
 case 'fdpf'

  Line = gcall(Line);
  gcall(PQ)
  PV = gcall(PV);
  SW = gcall(SW);
  gisland(Bus)

 case 'l'

  Line = gcall(Line);
  gcall(PQ)
  PV = gcall(PV);
  SW = gcall(SW);
  gisland(Bus)
  Gycall(Line)
  Gycall(PQ)
  Gycall(PV)
  Gycall(SW)
  Gyisland(Bus)


  
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  Fxcall(PV)
  Fxcall(SW)

 case 'kg'

  Line = gcall(Line);
  gcall(PQ)
  gisland(Bus)
  Gycall(Line)
  Gycall(PQ)
  Gyisland(Bus)


  
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  
 case 'kgpf'

  global PV SW
  Line = gcall(Line);
  gcall(PQ)
  PV = gcall(PV);
  greactive(SW)
  glambda(SW,1,DAE.kg)
  gisland(Bus)
  Gycall(Line)
  Gycall(PQ)
  Gycall(PV)
  Gyreactive(SW)
  Gyisland(Bus)


  
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  
 case 'n'

  Line = gcall(Line);
  gcall(PQ)
  PV = gcall(PV);
  SW = gcall(SW);
  gisland(Bus)
  Gycall(Line)
  Gycall(PQ)
  Gycall(PV)
  Gycall(SW)
  Gyisland(Bus)


 case 'i'

  Line = gcall(Line);
  gcall(PQ)
  PV = gcall(PV);
  SW = gcall(SW);
  gisland(Bus)
  Gycall(Line)
  Gycall(PQ)
  Gycall(PV)
  Gycall(SW)
  Gyisland(Bus)


  
  if DAE.n > 0
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  end 

  Fxcall(PV)
  Fxcall(SW)

 case '5'

  
end
