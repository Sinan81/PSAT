function fm_wcall
%FM_WCALL writes the function FM_CALL for the component calls.
%         and uses the information in Comp.prop for setting
%         the right calls. Comp.prop is organized as follows:
%         comp(i,:) = [x1 x2 x3 x4 x5 xi x0 xt]
%
%         if x1 -> call for algebraic equations
%         if x2 -> call for algebraic Jacobians
%         if x3 -> call for state equations
%         if x4 -> call for state Jacobians
%         if x5 -> call for non-windup limits
%         if xi -> component used in power flow computations
%         if x0 -> call for initializations
%         if xt -> call for current simulation time
%                  (-1 is used for static analysis)
%
%         Comp.prop is stored in the "comp.ini" file.
%
%FM_WCALL
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    22-Aug-2003
%Update:    03-Nov-2005
%Version:   1.2.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Settings

fm_var

% -------------------------------------------------------------------------
%  Opening file "fm_call.m" for writing
% -------------------------------------------------------------------------

if Settings.local
  fid = fopen([Path.local,'fm_call.m'], 'wt');
else
  [fid,msg] = fopen([Path.psat,'fm_call.m'], 'wt');
  if fid == -1
    fm_disp(msg)
    fid = fopen([Path.local,'fm_call.m'], 'wt');
  end
end
count = fprintf(fid,'function fm_call(flag)\n\n');

count = fprintf(fid,'\n%%FM_CALL calls component equations');
count = fprintf(fid,'\n%%');
count = fprintf(fid,'\n%%FM_CALL(CASE)');
count = fprintf(fid,'\n%%  CASE ''1''  algebraic equations');
count = fprintf(fid,'\n%%  CASE ''pq'' load algebraic equations');
count = fprintf(fid,'\n%%  CASE ''3''  differential equations');
count = fprintf(fid,'\n%%  CASE ''1r'' algebraic equations for Rosenbrock method');
count = fprintf(fid,'\n%%  CASE ''4''  state Jacobians');
count = fprintf(fid,'\n%%  CASE ''0''  initialization');
count = fprintf(fid,'\n%%  CASE ''l''  full set of equations and Jacobians');
count = fprintf(fid,'\n%%  CASE ''kg'' as "L" option but for distributed slack bus');
count = fprintf(fid,'\n%%  CASE ''n''  algebraic equations and Jacobians');
count = fprintf(fid,'\n%%  CASE ''i''  set initial point');
count = fprintf(fid,'\n%%  CASE ''5''  non-windup limits');
count = fprintf(fid,'\n%%');
count = fprintf(fid,'\n%%see also FM_WCALL\n\n');
count = fprintf(fid,'fm_var\n\n');
count = fprintf(fid,'switch flag\n\n');

% -------------------------------------------------------------------------
% look for loaded components
% -------------------------------------------------------------------------
Comp.prop(:,10) = 0;
for i = 1:Comp.n
  ncompi = eval([Comp.names{i},'.n']);
  if ncompi, Comp.prop(i,10) = 1; end
end

cidx1 = find(Comp.prop(:,10));
prop1 = Comp.prop(cidx1,1:9);
s11 = buildcell(cidx1,prop1(:,1),'gcall');
s12 = buildcell(cidx1,prop1(:,2),'Gycall');
s13 = buildcell(cidx1,prop1(:,3),'fcall');
s14 = buildcell(cidx1,prop1(:,4),'Fxcall');
s15 = buildcell(cidx1,prop1(:,5),'windup');

cidx2 = find(Comp.prop(1:end-2,10));
prop2 = Comp.prop(cidx2,1:9);
s20 = buildcell(cidx2,prop2(:,7),'setx0');
s21 = buildcell(cidx2,prop2(:,1),'gcall');
s22 = buildcell(cidx2,prop2(:,2),'Gycall');
s23 = buildcell(cidx2,prop2(:,3),'fcall');
s24 = buildcell(cidx2,prop2(:,4),'Fxcall');

gisland = '  gisland(Bus)\n';
gyisland = '  Gyisland(Bus)\n';

% -------------------------------------------------------------------------
% call algebraic equations
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''gen''\n\n');
idx = find(sum(prop2(:,[8 9]),2));
count = fprintf(fid,'  %s\n',s21{idx});

% -------------------------------------------------------------------------
% call algebraic equations of shunt components
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''load''\n\n');
idx = find(prod(prop2(:,[1 8]),2));
count = fprintf(fid,'  %s\n',s21{idx});
count = fprintf(fid,gisland);

% -------------------------------------------------------------------------
% call algebraic equations
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''gen0''\n\n');
idx = find(sum(prop2(:,[8 9]),2) & prop2(:,6));
count = fprintf(fid,'  %s\n',s21{idx});

% -------------------------------------------------------------------------
% call algebraic equations of shunt components
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''load0''\n\n');
idx = find(prod(prop2(:,[1 6 8]),2));
count = fprintf(fid,'  %s\n',s21{idx});
count = fprintf(fid,gisland);

% -------------------------------------------------------------------------
% call differential equations
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''3''\n\n');
idx = find(prop2(:,3));
count = fprintf(fid,'  %s\n',s23{idx});

% -------------------------------------------------------------------------
% call algebraic equations for Rosenbrock method
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''1r''\n\n');
idx = find(prop1(:,1));
count = fprintf(fid,'  %s\n',s11{idx});
count = fprintf(fid,gisland);

% -------------------------------------------------------------------------
% call algebraic equations of series component
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''series''\n\n');
idx = find(prop1(:,9));
count = fprintf(fid,'  %s\n',s11{idx});
count = fprintf(fid,gisland);

% -------------------------------------------------------------------------
% call DAE Jacobians
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''4''\n');
writejacs(fid)
idx = find(prop2(:,4));
count = fprintf(fid,'  %s\n',s24{idx});

% -------------------------------------------------------------------------
% call initialization functions
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''0''\n\n');
idx = find(prop2(:,7));
count = fprintf(fid,'  %s\n',s20{idx});

% -------------------------------------------------------------------------
% call the complete set of algebraic equations
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''fdpf''\n\n');
idx = find(prod(prop1(:,[1 6]),2));
count = fprintf(fid,'  %s\n',s11{idx});
count = fprintf(fid,gisland);

% -------------------------------------------------------------------------
% call the complete set of equations and Jacobians
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''l''\n\n');
idx = find(prod(prop1(:,[1 6]),2));
count = fprintf(fid,'  %s\n',s11{idx});
count = fprintf(fid,gisland);
idx = find(prod(prop1(:,[2 6]),2));
count = fprintf(fid,'  %s\n',s12{idx});
count = fprintf(fid,gyisland);
count = fprintf(fid,'\n\n');
idx = find(prod(prop1(:,[3 6]),2));
count = fprintf(fid,'  %s\n',s13{idx});
writejacs(fid)
idx = find(prod(prop1(:,[4 6]),2));
count = fprintf(fid,'  %s\n',s14{idx});

% -------------------------------------------------------------------------
% call the complete set of eqns and Jacs for distributed slack bus
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''kg''\n\n');
idx = find(prop2(:,1));
count = fprintf(fid,'  %s\n',s21{idx});
count = fprintf(fid,gisland);
idx = find(prop2(:,2));
count = fprintf(fid,'  %s\n',s22{idx});
count = fprintf(fid,gyisland);
count = fprintf(fid,'\n\n');
idx = find(prop2(:,3));
count = fprintf(fid,'  %s\n',s23{idx});
writejacs(fid)
idx = find(prop2(:,4));
count = fprintf(fid,'  %s\n',s24{idx});

% -------------------------------------------------------------------------
% call the complete set of eqns and Jacs for distributed slack bus
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''kgpf''\n\n');
count = fprintf(fid,'  global PV SW\n');
idx = find(prod(prop2(:,[1 6]),2));
count = fprintf(fid,'  %s\n',s21{idx});
count = fprintf(fid,'  PV = gcall(PV);\n');
count = fprintf(fid,'  greactive(SW)\n');
count = fprintf(fid,'  glambda(SW,1,DAE.kg)\n');
count = fprintf(fid,gisland);
idx = find(prod(prop2(:,[2 6]),2));
count = fprintf(fid,'  %s\n',s22{idx});
count = fprintf(fid,'  Gycall(PV)\n');
count = fprintf(fid,'  Gyreactive(SW)\n');
count = fprintf(fid,gyisland);
count = fprintf(fid,'\n\n');
idx = find(prod(prop2(:,[3 6]),2));
count = fprintf(fid,'  %s\n',s23{idx});
writejacs(fid)
idx = find(prod(prop2(:,[4 6]),2));
count = fprintf(fid,'  %s\n',s24{idx});

% -------------------------------------------------------------------------
% calling algebraic equations and Jacobians
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''n''\n\n');
idx = find(prop1(:,1));
count = fprintf(fid,'  %s\n',s11{idx});
count = fprintf(fid,gisland);
idx = find(prop1(:,2));
count = fprintf(fid,'  %s\n',s12{idx});
count = fprintf(fid,gyisland);
count = fprintf(fid,'\n');

% -------------------------------------------------------------------------
% call all the functions for setting initial point
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''i''\n\n');
idx = find(prop1(:,1));
count = fprintf(fid,'  %s\n',s11{idx});
count = fprintf(fid,gisland);
idx = find(prop1(:,2));
count = fprintf(fid,'  %s\n',s12{idx});
count = fprintf(fid,gyisland);
count = fprintf(fid,'\n\n');
idx = find(prop1(:,3));
count = fprintf(fid,'  %s\n',s13{idx});
count = fprintf(fid,'\n  if DAE.n > 0');
writejacs(fid)
count = fprintf(fid,'  end \n\n');
idx = find(prop1(:,4));
count = fprintf(fid,'  %s\n',s14{idx});

% -------------------------------------------------------------------------
% call saturation functions
% -------------------------------------------------------------------------
count = fprintf(fid,'\n case ''5''\n\n');
idx = find(prop1(:,5));
count = fprintf(fid,'  %s\n',s15{idx});

% -------------------------------------------------------------------------
%  close "fm_call.m"
% -------------------------------------------------------------------------
count = fprintf(fid,'\nend\n');
count = fclose(fid);
cd(Path.local);


% -------------------------------------------------------------------------
% function for writing Jacobian initialization
% -------------------------------------------------------------------------
function writejacs(fid)

count = fprintf(fid,'\n  DAE.Fx = sparse(DAE.n,DAE.n);');
count = fprintf(fid,'\n  DAE.Fy = sparse(DAE.n,DAE.m);');
count = fprintf(fid,'\n  DAE.Gx = sparse(DAE.m,DAE.n);\n');


% -------------------------------------------------------------------------
% function for building component call function cells
% -------------------------------------------------------------------------
function out = buildcell(j,idx,type)

global Comp Settings

out = cell(length(idx),1);

h = find(idx <= 1);
k = j(h);
if Settings.octave
  c = Comp.names(k);
  out(h) = fm_strjoin(type,'_',lower(c),'(',c,')');
else
  out(h) = fm_strjoin(type,'(',{Comp.names{k}}',')');
end

h = find(idx == 2);
k = j(h);
if Settings.octave
  c = Comp.names(k);
  out(h) = fm_strjoin(c,' = ',type,'_',lower(c),'(',c,');');
else
  str = [' = ',type,'('];
  out(h) = fm_strjoin({Comp.names{k}}',str,{Comp.names{k}}',');');
end