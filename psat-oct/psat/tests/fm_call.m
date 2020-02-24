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

  Line = gcall_line(Line);
  gcall_pq(PQ)

 case 'load'

  gcall_pq(PQ)
  gisland_bus(Bus)

 case 'gen0'

  Line = gcall_line(Line);
  gcall_pq(PQ)

 case 'load0'

  gcall_pq(PQ)
  gisland_bus(Bus)

 case '3'

  
 case '1r'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)

 case 'series'

  Line = gcall_line(Line);
  gisland_bus(Bus)

 case '4'

  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  
 case '0'

  
 case 'fdpf'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)

 case 'l'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Gycall_pv(PV)
  Gycall_sw(SW)
  Gyisland_bus(Bus)


  
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  Fxcall_pv(PV)
  Fxcall_sw(SW)

 case 'kg'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Gyisland_bus(Bus)


  
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  
 case 'kgpf'

  global PV SW
  Line = gcall_line(Line);
  gcall_pq(PQ)
  PV = gcall_pv(PV);
  greactive_sw(SW)
  glambda_sw(SW,1,DAE.kg)
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Gycall_pv(PV)
  Gyreactive_sw(SW)
  Gyisland_bus(Bus)


  
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  
 case 'n'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Gycall_pv(PV)
  Gycall_sw(SW)
  Gyisland_bus(Bus)


 case 'i'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Gycall_pv(PV)
  Gycall_sw(SW)
  Gyisland_bus(Bus)


  
  if DAE.n > 0
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  end 

  Fxcall_pv(PV)
  Fxcall_sw(SW)

 case '5'

  
end
