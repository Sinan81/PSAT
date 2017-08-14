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

  fcall_syn(Syn)
  Exc = fcall_exc(Exc);

 case '1r'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  Syn = gcall_syn(Syn);
  gcall_exc(Exc)
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
  Fxcall_syn(Syn)
  Fxcall_exc(Exc)

 case '0'

  Syn = setx0_syn(Syn);
  Exc = setx0_exc(Exc);

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
  Syn = gcall_syn(Syn);
  gcall_exc(Exc)
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Syn = Gycall_syn(Syn);
  Gycall_exc(Exc)
  Gyisland_bus(Bus)


  fcall_syn(Syn)
  Exc = fcall_exc(Exc);

  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  Fxcall_syn(Syn)
  Fxcall_exc(Exc)

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
  Syn = gcall_syn(Syn);
  gcall_exc(Exc)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Syn = Gycall_syn(Syn);
  Gycall_exc(Exc)
  Gycall_pv(PV)
  Gycall_sw(SW)
  Gyisland_bus(Bus)


 case 'i'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  Syn = gcall_syn(Syn);
  gcall_exc(Exc)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Syn = Gycall_syn(Syn);
  Gycall_exc(Exc)
  Gycall_pv(PV)
  Gycall_sw(SW)
  Gyisland_bus(Bus)


  fcall_syn(Syn)
  Exc = fcall_exc(Exc);

  if DAE.n > 0
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  end 

  Fxcall_syn(Syn)
  Fxcall_exc(Exc)
  Fxcall_pv(PV)
  Fxcall_sw(SW)

 case '5'

  windup_exc(Exc)

end
