function fm_build
%FM_BUILD build new component functions (Symbolic Toolbox is needed)
%
%FM_BUILD
%
%see also FM_MAKE FM_COMPONENT
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    19-Dec-2003
%Version:   1.0.1
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Comp Settings Fig Path
global Algeb Buses Initl Param Servc State

% ***********************************************************************
% some control variables
error_v = [];
lasterr('');
null = '0';

% useful strings
c_name = Comp.name;
c_name(1) = upper(c_name(1));

% variable arrays
state_vect = varvect(State.name, ' ');
algeb_vect = varvect(Algeb.name, ' ');
param_vect = varvect(Param.name, ' ');
initl_vect = varvect(Initl.name, ' ');
servc_vect = varvect(Servc.name, ' ');
pq_Servc = 0;

% equation arrays
servc_eq = varvect(Servc.eq,'; ');
state_eq = varvect(State.eq,'; ');
algeb_eq = varvect(Algeb.eq,'; ');

% ********************************************************************************
% check equations
if State.neq > 0
  state_check = strmatch('null',State.eq,'exact');
  if state_check
    error_v = [error_v; ...
               fm_strjoin('Differential equation for "', ...
                      State.eqidx(state_check), ...
                      '" has not been defined.')];
  end
end
if Servc.neq > 0
  servc_foo = fm_strjoin(Servc.type,Servc.eq);
  servc_check = strmatch('Innernull',servc_foo,'exact');
  servc_check = [servc_check; strmatch('Outputnull',servc_foo,'exact')];
  if servc_check
    error_v = [error_v; ...
               fm_strjoin('Service equation for "', ...
                      Servc.eqidx(servc_check), ...
                      '" has not been defined.')];
  end
end

% ********************************************************************************
% check variable usage
servc_idx = [strmatch('Inner',Servc.type); strmatch('Output',Servc.type)];
total_var = [State.name; Algeb.name; Servc.eqidx(servc_idx); Param.name; Initl.name];
total_eqn = [' ',servc_eq,' ',state_eq,' ',algeb_eq,' ',varvect(State.time,'*'),' '];
for i = 1:length(total_var)
  idx = findstr(total_eqn,total_var{i});
  if isempty(idx)
    error_v{end+1,1} = ['The variable "',total_var{i},'" is not used in any equation.'];
  else
    before = total_eqn(idx-1);
    after  = total_eqn(idx+length(total_var{i}));
    check = 1;
    for j = 1:length(idx)
      a = double(after(j));       b = double(before(j));
      a1 = ~isletter(after(j));   a2 = (a ~= 95);  a3 = (a > 57 || a < 48);
      b1 = ~isletter(before(j));  b2 = (b ~= 95);  b3 = (b > 57 || b < 48);
      if a1 && a2 && a3 && b1 && b2 && b3, check = 0; break, end
    end
    if check
      error_v{end+1,1} = ['The variable "',total_var{i}, ...
                          '" is not used in any equation.'];
    end
  end
end

% ********************************************************************************
% symbolic variables
try
  if state_vect, eval(['syms ',state_vect]), end
  if algeb_vect, eval(['syms ',algeb_vect]), end
  if param_vect, eval(['syms ',param_vect]), end
  if servc_vect, eval(['syms ',servc_vect]), end
  if initl_vect, eval(['syms ',initl_vect]), end

  % compute Jacobians matrices (Maple Symbolic Toolbox)
  if ~isempty(state_eq)
    if ~isempty(state_vect)
      eval(['Fx = jacobian([',state_eq, '],[', state_vect, ']);']);
    end
    if ~isempty(algeb_vect)
      eval(['Fy = jacobian([',state_eq, '],[', algeb_vect, ']);']);
    end
    if ~isempty(servc_vect)
      eval(['Fz = jacobian([',state_eq, '],[', servc_vect, ']);']);
    end
    if pq_Servc
      eval(['Fpq = jacobian([',state_eq, '],[', pq_vect, ']);']);
    end
  end
  if ~isempty(algeb_eq)
    if ~isempty(state_vect)
      eval(['Gx = jacobian([',algeb_eq, '],[', state_vect, ']);']);
    end
    if ~isempty(algeb_vect)
      eval(['Gy = jacobian([',algeb_eq, '],[', algeb_vect, ']);']);
    end
    if ~isempty(servc_vect)
      eval(['Gz = jacobian([',algeb_eq, '],[', servc_vect, ']);']);
    end
    if pq_Servc
      eval(['Gpq = jacobian([',alg_eqeb, '],[', pq_vect, ']);']);
    end
  end
  if ~isempty(servc_eq)
    if ~isempty(state_vect)
      eval(['Zx = jacobian([',servc_eq, '],[', state_vect, ']);']);
    end
    if ~isempty(algeb_vect)
      eval(['Zy = jacobian([',servc_eq, '],[', algeb_vect, ']);']);
    end
    if ~isempty(servc_vect)
      eval(['Zz = jacobian([',servc_eq, '],[', servc_vect, ']);']);
    end
    if pq_Servc
      eval(['Zpq = jacobian([',servc_eq, '],[', pq_vect, ']);']);
    end
  end
end

% ********************************************************************************
% check synthax of equations
for i = 1:State.neq
  try
    eval([State.eq{i,1},';'])
  catch
    error_v{end+1,1} = [lasterr, ' (In differential equation "', ...
                        State.eq{i,1}, '")'];
  end
  try
    eval([State.init{i,1},';'])
  catch
    error_v{end+1,1} = [lasterr, ' (In state variable  "', ...
                        State.name{i,1}, '" initialization expression)'];
  end
  state_init{i,1} = vectorize(State.init{i,1});
end
for i = 1:Algeb.neq
  try
    eval([Algeb.eq{i,1},';'])
  catch
    error_v{end+1,1} = [lasterr, ' (In algebraic equation "', ...
                        State.eq{i,1}, '")'];
  end
end
for j = 1:Servc.neq
  try
    eval([Servc.eq{i,1},';'])
  catch
    error_v{end+1,1} = [lasterr, ' (In service equation "', ...
                        Servc.eqidx{i,1}, '")'];
  end
end

% check component name
if isempty(Comp.name)
  error_v{end+1,1} = 'Component name is empty.';
  return
end

% ********************************************************************************
% display errors
if ~isempty(error_v)
  error_v = fm_strjoin('Error#',num2str([1:length(error_v)]'),': ',error_v);
  error_v = [{['REPORT OF ERRORS ENCOUNTERED WHILE BUILDING ', ...
               'NEW COMPONENT "',Comp.name,'.m"']}; error_v];
  error_v{end+1,1} = ['BUILDING NEW COMPONENT FILE "', ...
                      Comp.name,'.m" FAILED'];
  fm_disp
  fm_disp(error_v{1:end-1})
  fm_disp(['BUILDING NEW COMPONENT FILE "',Comp.name,'.m" FAILED'])

  fm_update
  set(findobj(Fig.update,'Tag','Listbox1'),'String',error_v, ...
                    'BackgroundColor','w', ...
                    'ForegroundColor','r', ...
                    'Enable','inactive', ...
                    'max',2, ...
                    'Value',[]);
  set(findobj(Fig.update,'Tag','Pushbutton2'),'Enable','off');
  return
end

% ***********************************************************************
% check for previous versions
a = what(Path.psat);
olderfile = strmatch(['fm_',Comp.name,'.m'],a.m,'exact');
if ~isempty(olderfile)
  uiwait(fm_choice(['Overwrite Existing File "fm_',Comp.name,'.m" ?']));
  if ~Settings.ok, return, end
end

% ***********************************************************************
% open new component file
fid = fopen([Path.psat, 'fm_', Comp.name,'.m'], 'wt');
if fid == -1
  fm_disp(['Cannot open file fm_',Comp.name,'. Check permissions'])
  return
end
fprintf(fid, ['function  fm_', Comp.name, '(flag)']);

% write help of the function
if isempty(Comp.descr)
  Comp.descr = ['Algebraic Differential Equation ', ...
                Comp.name, '.m'];
end
fprintf(fid, ['\n\n%%FM_', upper(Comp.name),' defines ',Comp.descr]);

% ********************************************************************
% data format .con
fprintf(fid, ['\n%%\n%%Data Format ', c_name, '.con:']);
fprintf(fid, '\n%%  col #%d: Bus %d number',[1:Buses.n;1:Buses.n]);
idx_inn = strmatch('Inner',  Servc.type, 'exact');
idx_inp = strmatch('Input',  Servc.type, 'exact');
idx_out = strmatch('Output', Servc.type, 'exact');

fprintf(fid, '\n%%  col #%d: Power rate [MVA]',Buses.n+1);
fprintf(fid, '\n%%  col #%d: Bus %d Voltage Rate [kV]', ...
        [Buses.n+1+[1:Buses.n];1:Buses.n]);
fprintf(fid, '\n%%  col #%d: Frequency rate [Hz]',2*Buses.n+2);
inip = 2*Buses.n+3;
endp  = 2*Buses.n+2+Param.n;
pidx = inip:endp;
for i=1:length(pidx)
  fprintf(fid, '\n%%  col #%d: %s %s [%s]', ...
          pidx(i),Param.name{i},Param.descr{i},Param.unit{i});
end

x_max = [1:State.n];
if State.n
  x_idx = strmatch('None',State.limit(:,1),'exact');
  x_max(x_idx) = [];
end
x_min = [1:State.n];
if State.n
  x_idx = strmatch('None',State.limit(:,2),'exact');
  x_min(x_idx) = [];
end
n_xmax = length(x_max); n_xmin = length(x_min);
for i=1:n_xmax
  fprintf(fid,'\n%%  col #%d: %s',endp+i, ...
          State.limit{x_max(i),1});
end
for i=1:n_xmin
  fprintf(fid,'\n%%  col #%d: %s',endp+n_xmax+i, ...
          State.limit{x_min(i),1});
end

s_max = [1:Servc.neq];
if Servc.n
  s_idx = strmatch('None',Servc.limit(:,1),'exact');
  s_max(s_idx) = [];
end
s_min = [1:Servc.neq];
if Servc.n
  s_idx = strmatch('None',Servc.limit(:,2),'exact');
  s_min(s_idx) = [];
end
n_smax = length(s_max); n_smin = length(s_min);
for i=1:n_smax
  fprintf(fid,'\n%%  col #%d: %s', ...
          endp+n_xmax+n_xmin+i,Servc.limit{s_max(i),1});
end
for i=1:n_smin
  fprintf(fid,'\n%%  col #%d: %s', ...
          endp+n_xmax+n_xmin+n_smax+i,Servc.limit{s_min(i),1});
end

okdata = 0;
nidx = 0;
if ~isempty(idx_inn) || ~isempty(idx_out)
  okdata = 1;
end
if Initl.n || okdata
  fprintf(fid, ['\n%% \n%%Data Structure: ', c_name, '.dat:']);
end
for i=1:Initl.n
  fprintf(fid,'\n%%  col #%d: %s', i,Initl.name{i});
end
if okdata
  nidx = length(idx_inn)+length(idx_out);
  iidx = [idx_inn;idx_out];
  for i=1:nidx
    fprintf(fid,'\n%%  col #%d: %s', ...
            Initl.n+i,Servc.eqidx{iidx(i)});
  end
end

% function calls
fprintf(fid, ['\n%% \n%%FM_', upper(Comp.name),'(FLAG)']);
if Comp.init
  fprintf(fid, ['\n%%   FLAG = 0 -> initialization']);
end
if ~isempty(algeb_eq)
  fprintf(fid, ['\n%%   FLAG = 1 -> algebraic equations']);
  fprintf(fid, ['\n%%   FLAG = 2 -> algebraic Jacobians']);
end
if ~isempty(state_eq);
  fprintf(fid, ['\n%%   FLAG = 3 -> differential equations']);
  fprintf(fid, ['\n%%   FLAG = 4 -> state Jacobians']);
end
if n_xmax || n_xmin > 0
  fprintf(fid, ['\n%%   FLAG = 5 -> non-windup limiters)']);
end
fprintf(fid, '\n%% \n%%Author:    File automatically generated by PSAT');
fprintf(fid, '\n%%Date:      %s',date);

% global variables
fprintf(fid, ['\n\nglobal ',c_name,' DAE Bus Settings']);

% ************************************************************************
% general settings
fprintf(fid, '\n');
for i=1:State.n
  fprintf(fid,'\n%s = DAE.x(%s.%s);',State.name{i},c_name, ...
          State.name{i});
end
if Algeb.n
  idx_v = strmatch('V',Algeb.name);
  idx_a = strmatch('t',Algeb.name);
  if idx_v
    num_v = strrep(Algeb.name(idx_v),'V','');
    if Buses.n == 1
      fprintf(fid,'\n%s = DAE.y(%s.bus+Bus.n);', ...
              Algeb.name{idx_v},c_name);
    else
      for i=1:length(idx_v)
        fprintf(fid,'\n%s = DAE.y(%s.bus%s+Bus.n);', ...
                Algeb.name{idx_v(i)},c_name,num_v{i});
      end
    end
  end
  if idx_a
    num_a = strrep(Algeb.name(idx_a),'theta','');
    if Buses.n == 1
      fprintf(fid,'\n%s = DAE.y(%s.bus);', ...
              Algeb.name{idx_a},c_name);
    else
      for i=1:length(idx_a)
        fprintf(fid,'\n%s = DAE.y(%s.bus%s);', ...
                Algeb.name{idx_a(i)},c_name,num_a{i});
      end
    end
  end
end
for i=1:Param.n
  fprintf(fid,'\n%s = %s.con(:,%d);',Param.name{i},c_name,pidx(i));
end
for i=1:n_xmax,
  fprintf(fid,'\n%s = %s.con(:,%d);',State.limit{x_max(i),1}, ...
	  c_name,endp+i);
end
for i=1:n_xmin,
  fprintf(fid,'\n%s = %s.con(:,%d);',State.limit{x_min(i),2}, ...
	  c_name,endp+n_xmax+i);
end
for i=1:n_smax,
  fprintf(fid,'\n%s = %s.con(:,%d);',Servc.limit{s_max(i),1}, ...
	  c_name,endp+n_xmax+n_xmin+i);
end
for i=1:n_smin,
  fprintf(fid,'\n%s = %s.con(:,%d);',Servc.limit{s_min(i),2}, ...
	  c_name,endp+n_xmax+n_xmin+n_smax+i);
end
for i=1:Initl.n,
  fprintf(fid,'\n%s = %s.dat(:,%d);',Initl.name{i},c_name,i);
end
for i=1:nidx,
  fprintf(fid,'\n%s = %s.dat(:,%d);',Servc.eqidx{iidx(i)},c_name, ...
	  Initl.n+i);
end

% **********************************************************************
% initialization
if Comp.init
  fprintf(fid, '\n\nswitch flag\n case 0 %% initialization');
  msg = ['Component'];
  idx_T = [1:State.n];
  idx = strmatch('None',State.time,'exact');
  idx_T(idx) = [];
  if idx_T
    fprintf(fid,'\n\n  %%check time constants');
  end
  for i=1:length(idx_T),
    fprintf(fid,['\n  idx = find(%s == 0);\n  if idx\n    ', ...
                 Comp.name,'warn(idx, ''Time constant %s ', ...
                 'cannot be zero. %s = 0.001 s will be used.''),\n  ' ...
                 'end'],State.time{idx_T(i)}, ...
                 State.time{idx_T(i)},State.time{idx_T(i)});
    fprintf(fid,'\n  %s.con(idx,%d) = 0.001;', ...
            c_name,pidx(strmatch(State.time{idx_T(i)}, ...
                                 Param.name,'exact')));
  end
  fprintf(fid,'\n\n  %%variable initialization');
  for i=1:State.n,
    fprintf(fid,'\n  DAE.x(%s.%s) = %s;',c_name,State.name{i},state_init{i});
    fprintf(fid,'\n  %s = DAE.x(%s.%s);',State.name{i},c_name,State.name{i});
  end
  for i=1:nidx,
    fprintf(fid,'\n  %s.dat(:,%d) = %s;',Initl.n+i,c_name,vectorize(Servc.eq{i}));
    fprintf(fid,'\n  %s = %s.dat(:,%d);',Servc.eqidx{iidx(i)},c_name,Initl.n+i);
  end
  for i=1:Initl.n
    fprintf(fid,'\n  %s.dat(:,%d) = %s;',c_name,i, ...
            strrep(Initl.name{i},'_0',''));
  end
  fprintf(fid,'\n\n  %%check limits');
  for i=1:n_xmax
    fprintf(fid,['\n  idx = find(%s > %s_max); if idx, ', ...
                 Comp.name,'warn(idx, '' State variable %s ', ...
                 'is over its maximum limit.''), end'], ...
            State.name{x_max(i)},State.name{x_max(i)}, ...
            State.name{x_max(i)});
  end
  for i=1:n_xmin
    fprintf(fid,['\n  idx = find(%s < %s_min); if idx, ', ...
                 Comp.name,'warn(idx, '' State variable %s ', ...
                 'is under its minimum limit.''), end'], ...
            State.name{x_min(i)},State.name{x_min(i)}, ...
            State.name{x_min(i)});
  end
  for i=1:n_smax
    fprintf(fid,['\n  idx = find(%s > %s_max); if idx, ', ...
                 Comp.name,'warn(idx, '' State variable %s ', ...
                 'is over its maximum limit.''), end'], ...
            Servc.name{s_max(i)},Servc.name{s_max(i)}, ...
            Servc.name{s_max(i)});
  end
  for i=1:n_smin
    fprintf(fid,['\n  idx = find(%s < %s_min); if idx, ', ...
                 Comp.name,'warn(idx, '' State variable %s ', ...
                 'is under its minimum limit.''), end'], ...
            Servc.name{s_min(i)},Servc.name{s_min(i)}, ...
            Servc.name{s_min(i)});
  end
  fprintf(fid,['\n  fm_disp(''Initialization of ',c_name, ...
               'components completed.'')\n']);
end

% **********************************************************************
% algebraic equations
if ~isempty(algeb_eq)
  if Comp.init
    fprintf(fid, '\n case 1 %% algebraic equations\n');
  else
    fprintf(fid, '\n\nswitch flag\n case 1 %% algebraic equations\n');
  end
end

aidx = [1:Algeb.neq];
idx = strmatch('null',Algeb.eq);
aidx(idx) = [];
idx = strmatch('0',Algeb.eq);
aidx(idx) = [];
for i = 1:length(aidx)
  if Buses.n == 1
    a1 = '';
  else
    a1 = num2str(ceil(aidx(i)/2));
  end
  if rem(aidx(i),2)
    fprintf(fid,'\n  DAE.g = DAE.g + sparse(%s.bus%s,1,%s,DAE.m,1);', ...
            c_name,a1,vectorize(Algeb.eq{aidx(i)}));
  else
    fprintf(fid,'\n  DAE.g = DAE.g + sparse(%s.bus%s+Bus.n,1,%s,DAE.m,1);', ...
            c_name,a1,vectorize(Algeb.eq{aidx(i)}));
  end
end

% ********************************************************************
% algebraic Jacobians

% substitution of inner service variables
for j = 1:5
  for i = 1:Servc.neq
    if strcmp(Servc.type{i},'Inner') && ~strcmp(Servc.eq{i},'null')
      state_eq = strrep(state_eq,Servc.eqidx{i},['(',Servc.eq{i},')']);
      algeb_eq = strrep(algeb_eq,Servc.eqidx{i},['(',Servc.eq{i},')']);
      servc_eq = strrep(servc_eq,Servc.eqidx{i},['(',Servc.eq{i},')']);
    end
  end
end

if ~isempty(algeb_eq)
  fprintf(fid, '\n\n case 2 %% algebraic Jacobians\n');
end
eqformat = '\n  DAE.J%d%d = DAE.J%d%d + sparse(%s.bus%s,%s.bus%s,%s,Bus.n,Bus.n);';

for j = 1:length(aidx)
  i = aidx(j);
  a1 = 2-rem(i,2);
  if Buses.n == 1
    a2 = '';
  else
    a2 = num2str(ceil(i/2));
  end
  for h = 1:Algeb.n
    type = Algeb.name{h,1};
    if strcmp(type(1), 'V');
      a3 = 2;
      if Buses.n == 1
        a4 = '';
      else
        a4 = type(2:length(type));
      end
    elseif strcmp(type(1:5), 'theta');
      a3 = 1;
      if Buses.n == 1
        a4 = '';
      else
        a4 = type(6:length(type));
      end
    end
    if ~strcmp(char(Gy(i,h)),'0')
      fprintf(fid,eqformat,a1,a3,a1,a3,c_name,a2,c_name,a4, ...
              vectorize(char(Gy(i,h))));
    end
  end
end

% check limits in case of state variable dependancies
Temp = 0;
for i = 1:Servc.neq; Temp = ~strcmp(Servc.limit{i},'None'); break; end
S = 0;
if Temp
  for i = 1:Servc.neq; S = ~strcmp(Servc.type{i},'Input'); break; end
end
if S
  fprintf(fid,'\n');
  for i = 1:length(Servc.eqidx)
    s_var = Servc.eqidx{i};
    for k = 1:Servc.neq; if strcmp(s_var,Servc.name{k}); break; end; end
    if ~strcmp(Servc.type{k},'Input') && ~isempty(findstr(algeb_eq,s_var))
      a = strcmp(Servc.limit{k,1},'None');
      b = strcmp(Servc.limit{k,2},'None');
      if ~a || ~b
        fprintf(fid, ['\n  if (']);
        if ~a
          fprintf(fid,[Servc.name{k},'(i) <= ',Servc.name{k},'_max(i)']);
        else
          fprintf(fid,'(');
        end
        if ~a && ~b
          fprintf(fid,' || '); end
        if ~b
          fprintf(fid,[Servc.name{k},'(i) >= ',Servc.name{k},'_min(i))']);
        else
          fprintf(fid,')');
        end
        fprintf(fid,'\n  end');
      end
    end
  end
end

% *********************************************************************
% differential & service equations
if ~isempty(state_eq)
  if Comp.init || ~isempty(algeb_eq)
    fprintf(fid, '\n\n case 3 %% differential equations\n');
  else
    fprintf(fid, '\n\nswitch flag\n case 3 %% differential equations\n');
  end
end

for i = 1:Servc.neq
  Temp = Servc.type{i};
  if strcmp(Temp,'Inner')
    s_eq = vectorize(Servc.eq{i});
    fprintf(fid,['\n  ',Servc.name{i},' = ',s_eq,';']);
    if ~strcmp(Servc.limit{i,1},'None')
      fprintf(fid, ['\n  ',Servc.name{i}, ...
                    ' = min(',Servc.name{i},',',Servc.name{i},'_max);']);
    end
    if ~strcmp(Servc.limit{i,2},'None')
      fprintf(fid, ['\n  ',Servc.name{i}, ...
                    ' = max(',Servc.name{i},',',Servc.name{i},'_min);']);
    end
   end
end

for i = 1:State.n
  if strcmp(State.nodyn{i},'Yes')
    fprintf(fid, ['\n  no_dyn_',State.name{i},' = find(',State.time{i},' == 0);']);
    fprintf(fid, ['\n  ', State.time{i}, '(no_dyn_',State.name{i},') = 1;']);
  end
  if strcmp(State.time{i},'None')
    s_eq = vectorize(State.eq{i});
  else
    s_eq = vectorize(['(',State.eq{i},')/',State.time{i}]);
  end
  fprintf(fid, ['\n  DAE.f(',c_name,'.',State.name{i},') = ',s_eq,';']);

  if strcmp(State.nodyn{i},'Yes')
    fprintf(fid, ['\n  DAE.f(',c_name,'.',State.name{i},'(no_dyn_',State.name{i},')) = 0;']);
  end
end

if State.n > 0; if strcmp(State.nodyn{State.n},'Yes'); fprintf(fid, '\n'); end; end

% set hard limits
fprintf(fid,'\n  %% non-windoup limits');
limfor1 = '\n  idx = find(%s >= %s_max && DAE.f(%s) > 0);';
limfor2 = '\n  if idx, DAE.f(%s(idx)) = 0; end';
limfor3 = '\n  DAE.x(%s) = min(%s,%s_max);';
limfor4 = '\n  idx = find(%s <= %s_min && DAE.f(%s) < 0);';
limfor5 = '\n  DAE.x(%s) = max(%s,%s_min);';
for i = 1:State.n
  varidx = [c_name,'.',State.name{i}];
  a = strcmp(State.limit{i,1},'None');
  if ~a
    fprintf(fid,limfor1,State.name{i},State.name{i},varidx);
    fprintf(fid,limfor2,State.name{i});
    fprintf(fid,limfor3,varidx,State.name{i},State.name{i});
  end
  b = strcmp(State.limit{i,2},'None');
  if ~b
    fprintf(fid,limfor4,State.name{i},State.name{i},varidx);
    fprintf(fid,limfor2,State.name{i});
    fprintf(fid,limfor5,varidx,State.name{i},State.name{i});
  end
end

fprintf(fid, '\n');

numdata = Initl.n;
for i = 1:Servc.neq
  Temp = Servc.type{i};
  if okdata && strcmp(Temp,'Inner')
    numdata = numdata + 1;
    fprintf(fid,['\n  ',c_name,'.dat(:,',int2str(numdata),') = ', Servc.name{i},';']);
  elseif strcmp(Temp,'Output')
    numdata = numdata + 1;
    s_eq = vectorize(Servc.eq{i});
    TempT = [c_name,'.dat(:,',int2str(numdata),')'];
    fprintf(fid,['\n  ',TempT,' = ',s_eq,';']);
    zz = ['z(',Servc.name{i},'_',Comp.name,'_idx)'];
    if ~strcmp(Servc.limit{i,1},'None')
      fprintf(fid, ['\n  ',TempT,' = min(',TempT,',',Servc.name{i},'_max);']);
    end
    if ~strcmp(Servc.limit{i,2},'None')
      fprintf(fid, ['\n  ',TempT,' = max(',TempT,',',Servc.name{i},'_min);']);
    end
    fprintf(fid,['\n  ',zz,' = ',zz,' + ',TempT,';']);
  end
end

fprintf(fid, '\n');

% *********************************************************************
% state variable Jacobians
if ~isempty(state_eq)
  fprintf(fid, '\n\n case 4 %% state variable Jacobians\n');
end

% DAE.Fx
for j = 1:State.n
  if strcmp(State.nodyn{j},'Yes')
    fprintf(fid, ['\n  no_dyn_',State.name{j},' = find(',State.time{j},' == 0);']);
    fprintf(fid, ['\n  ', State.time{j}, '(no_dyn_',State.name{j},') = 1;']);
  end
end
fprintf(fid, '\n');
if State.n, fprintf(fid,'\n  %% DAE.Fx'); end
fxformat = '\n  DAE.Fx = DAE.Fx + sparse(%s,%s,%s,DAE.n,DAE.n);';
for j = 1:State.n
  x_idx1 = [c_name,'.',State.name{j}];
  for i = 1:State.n
    x_idx2 = [c_name,'.',State.name{i}];
    if strcmp(State.time{j},'None')  && ~strcmp(char(Fx(j,i)),'0')
      fxexp = vectorize(char(Fx(j,i)));
    else
      fxexp = ['(',vectorize(char(Fx(j,i))),')./',State.time{j}];
    end
    if ~strcmp(fxexp,['(0)./',State.time{j}])
      fprintf(fid,fxformat,x_idx1,x_idx2,fxexp);
    end
  end
end

fprintf(fid,'\n');

% DAE.Fy
if State.n && Algeb.n, fprintf(fid,'\n  %% DAE.Fy'); end
fyformat = '\n  DAE.Fy = DAE.Fy + sparse(%s,%s,%s,DAE.n,DAE.m);';
for j = 1:State.n
  x_idx1 = [c_name,'.',State.name{j}];
  for i = 1:Algeb.n
    type = Algeb.name{i};
    if strcmp(type(1),'V')
      if Buses.n == 1
        x_idx2 = [c_name,'.bus','','+Bus.n'];
      else
        x_idx2 = [c_name,'.bus',type(2:length(type)),'+Bus.n'];
      end
    elseif strcmp(type(1:5),'theta')
      if Buses.n == 1
        x_idx2 = [c_name,'.bus',''];
      else
        x_idx2 = [c_name,'.bus',type(6:length(type))];
      end
    end
    if strcmp(State.time{j},'None') && ~strcmp(char(Fy(j,i)),'0')
      fyexp = vectorize(char(Fy(j,i)));
    else
      fyexp = ['(',vectorize(char(Fy(j,i))),')./',State.time{j}];
    end
    if ~strcmp(fyexp,['(0)./',State.time{j}])
      fprintf(fid,fyformat,x_idx1,x_idx2,fyexp);
    end
  end
end

fprintf(fid,'\n');

% DAE.Gx
if State.n && Algeb.n, fprintf(fid,'\n  %% DAE.Gx'); end
gxformat = '\n  DAE.Gx = DAE.Gx + sparse(%s,%s,%s,DAE.m,DAE.n);';
for j = 1:Algeb.neq
  if ~strcmp(Algeb.eq{1},'null')
    type = Algeb.eqidx{j,1};
    if strcmp(type(1),'P')
      if Buses.n == 1
        a_idx = [c_name,'.bus',''];
      else
        a_idx = [c_name,'.bus',type(2:length(type))];
      end
    elseif strcmp(type(1),'Q')
      if Buses.n == 1
        a_idx = [c_name,'.bus','','+Bus.n'];
      else
        a_idx = [c_name,'.bus',type(2:length(type)),'+Bus.n'];
      end
    end
    for h = 1:State.n
      x_idx = [c_name,'.',State.name{h}];
      algexp = vectorize(char(Gx(j,h)));
      if ~strcmp(algexp,'0')
        fprintf(fid,gxformat,a_idx,x_idx,algexp);
      end
    end
  end
end

%if State.n > 0, fprintf(fid, ['\n\n  end']); end

% ***************************************************************
% non-windup limiters
if n_xmax || n_xmin
  fprintf(fid, '\n\n case 5 %% non-windup limiters\n');
  for i = 1:State.n
    M = ~strcmp(State.limit{i,1},'None');
    m = ~strcmp(State.limit{i,2},'None');
    if M || m
      fprintf(fid, ['\n  idx = find((']);
      if M, fprintf(fid,'%s >= %s_max',State.name{i},State.name{i}); end
      if M && m; fprintf(fid,' || '); end
      if m, fprintf(fid,'%s <= %s_min',State.name{i},State.name{i}); end
      fprintf(fid,[') && DAE.f(',c_name,'.%s) == 0);'],State.name{i});
      fprintf(fid, '\n  if ~isempty(idx)');
      fprintf(fid,['\n    k = ',c_name,'.%s(idx);'],State.name{i});
      fprintf(fid,['\n    DAE.tn(k) = 0;']);
      fprintf(fid,['\n    DAE.Ac(:,k) = 0;']);
      fprintf(fid,['\n    DAE.Ac(k,:) = 0;']);
      fprintf(fid,['\n    DAE.Ac = DAE.Ac - sparse(k,k,1,DAE.m+DAE.n,DAE.m+DAE.n);']);
      fprintf(fid,['\n  end']);
    end
  end
end

fprintf(fid, '\n\nend\n');

% *******************************************************************
% warning message function
fprintf(fid,'\n\n%% -------------------------------------------------------------------');
fprintf(fid,'\n%% function for creating warning messages');
fprintf(fid,['\nfunction ',Comp.name,'warn(idx, msg)']);
%fprintf(fid,['\nglobal ',c_name]);
fprintf(fid,['\nfm_disp(fm_strjoin(''Warning: ',upper(Comp.name),' #'',int2str(idx),msg))']);

% close component file and return
fclose(fid);
fm_choice(['Function "fm_',Comp.name,'" built.'],2)

% ****************************************************************
function vect = varvect(vect,sep)

n = length(sep)-1;
if iscell(vect)
  vect = fm_strjoin(vect,'#');
  vect = strrep([vect{:}],'#',sep);
  vect(end-n:end) = [];
end