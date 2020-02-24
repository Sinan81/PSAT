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
  gcall_fault(Fault)

 case 'load'

  gcall_pq(PQ)
  gcall_fault(Fault)
  gisland_bus(Bus)

 case 'gen0'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  gcall_fault(Fault)

 case 'load0'

  gcall_pq(PQ)
  gcall_fault(Fault)
  gisland_bus(Bus)

 case '3'

  fcall_syn(Syn)
  Exc = fcall_exc(Exc);
  Tg = fcall_tg(Tg);

 case '1r'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  gcall_fault(Fault)
  Syn = gcall_syn(Syn);
  gcall_exc(Exc)
  gcall_tg(Tg)
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
  Fxcall_tg(Tg)

 case '0'

  Syn = setx0_syn(Syn);
  Exc = setx0_exc(Exc);
  Tg = setx0_tg(Tg);

 case 'fdpf'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  gcall_fault(Fault)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)

 case 'l'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  gcall_fault(Fault)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Gycall_fault(Fault)
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
  gcall_fault(Fault)
  Syn = gcall_syn(Syn);
  gcall_exc(Exc)
  gcall_tg(Tg)
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Gycall_fault(Fault)
  Syn = Gycall_syn(Syn);
  Gycall_exc(Exc)
  Gycall_tg(Tg)
  Gyisland_bus(Bus)


  fcall_syn(Syn)
  Exc = fcall_exc(Exc);
  Tg = fcall_tg(Tg);

  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  Fxcall_syn(Syn)
  Fxcall_exc(Exc)
  Fxcall_tg(Tg)

 case 'kgpf'

  global PV SW
  Line = gcall_line(Line);
  gcall_pq(PQ)
  gcall_fault(Fault)
  PV = gcall_pv(PV);
  greactive_sw(SW)
  glambda_sw(SW,1,DAE.kg)
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Gycall_fault(Fault)
  Gycall_pv(PV)
  Gyreactive_sw(SW)
  Gyisland_bus(Bus)


  
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  
 case 'n'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  gcall_fault(Fault)
  Syn = gcall_syn(Syn);
  gcall_exc(Exc)
  gcall_tg(Tg)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Gycall_fault(Fault)
  Syn = Gycall_syn(Syn);
  Gycall_exc(Exc)
  Gycall_tg(Tg)
  Gycall_pv(PV)
  Gycall_sw(SW)
  Gyisland_bus(Bus)


 case 'i'

  Line = gcall_line(Line);
  gcall_pq(PQ)
  gcall_fault(Fault)
  Syn = gcall_syn(Syn);
  gcall_exc(Exc)
  gcall_tg(Tg)
  PV = gcall_pv(PV);
  SW = gcall_sw(SW);
  gisland_bus(Bus)
  Gycall_line(Line)
  Gycall_pq(PQ)
  Gycall_fault(Fault)
  Syn = Gycall_syn(Syn);
  Gycall_exc(Exc)
  Gycall_tg(Tg)
  Gycall_pv(PV)
  Gycall_sw(SW)
  Gyisland_bus(Bus)


  fcall_syn(Syn)
  Exc = fcall_exc(Exc);
  Tg = fcall_tg(Tg);

  if DAE.n > 0
  DAE.Fx = sparse(DAE.n,DAE.n);
  DAE.Fy = sparse(DAE.n,DAE.m);
  DAE.Gx = sparse(DAE.m,DAE.n);
  end 

  Fxcall_syn(Syn)
  Fxcall_exc(Exc)
  Fxcall_tg(Tg)
  Fxcall_pv(PV)
  Fxcall_sw(SW)

 case '5'

  windup_exc(Exc)

end
