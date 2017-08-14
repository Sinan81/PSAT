function fm_limit
% FM_LIMIT compute Limit-Induced Bifurcation (LIB)
%          by means of a Newton-Raphson routine.
%
% FM_LIMIT
%
%     LIB.type:  1 = 'Vmax' for maximum voltage limit
%                2 = 'Vmin' for minimum voltage limit
%                3 = 'Qmax' for maximum reactive power limit
%                4 = 'Qmin' for minimum reactive power limit
%     LIB.slack:  0   ->   single slack bus
%                 1   ->   distribuited slack bus
%     LIB.bus:    bus number at which the limit will be applied
%     LIB.lambda: the critical value of lambda at the LIB eq. point
%
%                                              d P   |
%     LIB.dpdl:  sensitivity coefficient    -------- |
%                                           d lambda |0
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Settings
fm_var

if ~autorun('LIB Direct Method',0), return, end

type   = LIB.type;
slack  = LIB.slack;
bus_no = LIB.selbus;

% check for loaded components
ncload = getnum(Mn) + getnum(Pl) +  getnum(Lines);
if ncload || DAE.n
  fm_disp('only PV, PQ and SW buses are allowed for LIB computations.')
  return
end

fm_disp('  ',1)
fm_disp('Newton-Rapshon Method for LIB Computation - Distribuited Slack Bus',1)
fm_disp(['Data file "',Path.data,File.data,'"'],1)
fm_disp

length(Snapshot.y);
DAE.y = Snapshot(1).y;
DAE.x = Snapshot(1).x;
DAE.Gy = Snapshot(1).Gy;

dynordold = DAE.n;

noDem = 0;
noSup = 0;
forcepq = Settings.forcepq;
Settings.forcepq = 1;
[Vmax,Vmin] = fm_vlim(1.2,0.8);
failed = 0;

if bus_no > Bus.n
  fm_disp('Bus_no exceeds bus number',2)
  failed = 1;
end
if bus_no < 1
  fm_disp('Bus_no should be an integer > 0',2)
  failed = 1;
end
bus_no = Bus.int(round(bus_no));

switch type
 case 1
  a = findbus(PQ,bus_no);
  if isempty(a)
    fm_disp('No PQ load found for the specified bus number',2)
    failed = 1;
  end
  eta = Vmax(a);
 case 2
  a = findbus(PQ,bus_no);
  if isempty(a)
    fm_disp('No PQ load found for the specified bus number',2)
    failed = 1;
  end
  eta = Vmin(a);
 case 3
  a = findbus(PV,bus_no);
  b = findbus(SW,bus_no);
  if isempty(a) && isempty(b),
    fm_disp('No generator found for the specified bus number',2)
    failed = 1;
  end
  if a
    PQ = add(PQ,pqdata(PV,a,'qmaxl','',0,0,1));
    eta = getvg(PV,a);
    PV = remove(PV,a);
  end
  if b
    PQ = add(PQ,pqdata(SW,b,'qmaxl','',0,0,1));
    eta = getvg(SW,b);
    SW = remove(SW,b);
    SW = add(SW,move2sw(PV));
  end
 case 4
  a = findbus(PV,bus_no);
  b = findbus(SW,bus_no);
  if isempty(a) && isempty(b),
    fm_disp('No generator found for the specified bus number',2)
    failed = 1;
  end
  if a
    PQ = add(PQ,pqdata(PV,a,'qminl','',0,0,1));
    eta = getvg(PV,a);
    PV = remove(PV,a);
  end
  if b
    PQ = add(PQ,pqdata(SW,b,'qminl','',0,0,1));
    eta = getvg(SW,b);
    SW = remove(SW,b);
    SW = add(SW,move2sw(PV));
  end
 otherwise
  fm_disp('ERROR: option "',num2str(type),'" is not defined.',2)
  failed = 1;
end

if failed
  DAE.n = dynordold;
  PQ = restore(PQ);
  PV = restore(PV);
  SW = restore(SW);
  return
end

% if no Demand.con is imposed, the load power direction
% is assumed to be equal to the PQ one
if Demand.n,
  no_dpq = findzero(Demand);
  if ~isempty(no_dpq),
    fm_disp
    for i = 1:length(no_dpq)
      fm_disp(['No power direction found in "Demand.con" for Bus ', ...
               Bus.names{Demand.bus(no_dpq(i))}])
    end
    fm_disp('Continuation load flow routine may have convergence problems.',2)
    fm_disp
  end
else
  noDem = 1;
end

% if no Supply.con is imposed, the generator power direction
% is assumed to be equal to the PV one
if Supply.n
  no_sp = findzero(Supply);
  if ~isempty(no_sp),
    fm_disp
    if length(no_sp) == Supply.n
      fm_disp(['No power directions found in "Supply.con" for all buses.'])
      fm_disp('Remove "Supply" components or set power directions.')
      fm_disp('Continuation power flow interrupted',2)
      if CPF.show, set(Fig.main,'Pointer','arrow'); end
      return
    else
      for i = 1:length(no_sp)
        fm_disp(['No power direction found in "Supply.con" for Bus ', ...
                 Bus.names{Supply.bus(no_sp(i))}])
      end
      fm_disp('Continuation power flow routine may have convergence problems.',2)
      fm_disp
    end
  end
else
  noSup = 1;
  if slack, SW = move2sup(SW); end
end

% size Jacobian matrices
if DAE.n ==0
  DAE.f = 0;
  DAE.x = 1;
  DAE.Fx = 1;
end
if isempty(DAE.f), DAE.f = 0; end
if DAE.n == 0, DAE.n = 1; end

DAE.Fl = sparse(DAE.n,1);
DAE.Fk = sparse(DAE.n,1);
Fc = sparse(DAE.n,1);
Kjac = sparse(1,DAE.m+DAE.n+2);
Cjac = sparse(1,DAE.m+DAE.n+2);
Cjac(DAE.n+Bus.n+bus_no) = 1;
Kjac(1,DAE.n+SW.refbus) = 1;

iter_max = Settings.lfmit;
iterazione = 0;
tol = Settings.lftol;
Settings.error = tol+1;

%  Power Flow Routine with inclusion of limit
tic;

fm_status('lib','init',iter_max,{'b'},{'-'},{'y'},[-1 5])

l_vect = [];
lambda = 1;
kg = 0;

while Settings.error > tol
  if (iterazione >= iter_max), break, end
  if ishandle(Fig.main)
    if ~get(Fig.main,'UserData'), break, end
  end

  DAE.Gl = sparse(DAE.m,1);
  DAE.Gk = sparse(DAE.m,1);

  % call components functions and models
  Line = gcall(Line);
  gcall(Shunt)
  Gycall(Line)
  Gycall(Shunt)
  if noDem
    glambda(PQ,lambda);
    Glcall(PQ);
  else
    gcall(PQ);
    glambda(Demand,lambda);
    Glcall(Demand);
  end

  glambda(Supply,lambda,slack*kg);
  Glcall(Supply);
  if slack, Gkcall(Supply); end

  if noSup
    glambda(PV,lambda,slack*kg)
    glambda(SW,lambda,kg)
    greactive(PV)
    if slack, Gkcall(PV), end
    Glcall(PV)
    Gyreactive(PV)
    Glcall(SW)
  else
    gcall(PV);
    Gycall(PV);
    glambda(SW,1,kg)
  end
  Gkcall(SW)
  greactive(SW)
  Gyreactive(SW)

  inc = -[DAE.Fx, DAE.Fy, DAE.Fl, DAE.Fk; DAE.Gx, DAE.Gy, DAE.Gl, DAE.Gk; Cjac; Kjac]\ ...
        [DAE.f; DAE.g; DAE.y(bus_no+Bus.n)-eta; DAE.y(SW.refbus)];
  DAE.x = DAE.x + inc(1:DAE.n);
  DAE.y = DAE.y + inc(1+DAE.n: DAE.m+DAE.n);
  lambda = lambda + inc(end-1);
  kg = kg + inc(end);

  Settings.error = max(abs(inc));
  iterazione = iterazione + 1;
  fm_status('lib','update',[iterazione, Settings.error],iterazione)
  fm_disp(['iteration = ',int2str(iterazione), ...
           '    lambda = ',num2str(lambda), ...
           '    kg = ',num2str(kg), ...
           '    err = ',num2str(Settings.error)],1)
end

fm_disp
fm_disp(['lambda critical = ',num2str(lambda)])

% sensitivity coefficients
% ===========================================================================
k_jac = Kjac([DAE.n+1:end-2, end]);
Dxf1c = [DAE.Gy,DAE.Gk;k_jac];
Dlf1c = [DAE.Gl;0];
d1 = DAE.m+1;
d2 = Demand.n+Supply.n;
Dpf1c = sparse(d1,d2);
Dpf1c = Dpf1c + sparse(Supply.bus,[1:Supply.n],-(lambda+kg),d1,d2);
Dpf1c = Dpf1c + sparse(Demand.bus,Supply.n+[1:Demand.n],lambda,d1,d2);

Dxf2c = Dxf1c;
Dxf2c(bus_no,:) = zeros(1,DAE.m+1);
Dxf2c(:,bus_no) = zeros(DAE.m+1,1);
Dxf2c(bus_no,bus_no) = 1;
Dlf2c = Dlf1c;
Dpf2c = Dpf1c;

mu = Dlf2c - Dxf2c*(Dxf1c\Dlf1c);

dl_dp = full((mu')*(Dxf2c*(Dxf1c\Dpf1c) - Dpf2c)/(mu'*mu))';

LIB.lambda = lambda;
LIB.dldp = dl_dp;

if Settings.matlab && Settings.hostver >= 7.14,
  LIB.bus = char([cell(fm_strjoin('s_',num2str(Supply.bus))); ...
                  cell(fm_strjoin('d_',num2str(Demand.bus)))]);
else
  LIB.bus = strvcat(fm_strjoin('s_',num2str(Supply.bus)), ...
                    fm_strjoin('d_',num2str(Demand.bus)));
end

% Update Pg, Qg, Pl and Ql
% ===========================================================================

DAE.g = zeros(DAE.m,1);
fm_call('load');
glambda(Demand,lambda)
Bus.Pl = DAE.g(Bus.a);
Bus.Ql = DAE.g(Bus.v);
fm_call('gen');
Bus.Pg = DAE.g(Bus.a);
Bus.Qg = DAE.g(Bus.v);
adjgen(PQ)

% display results
% ===========================================================================
Settings.lftime = toc;
Settings.iter = iterazione;
if iterazione >= iter_max
  fm_disp(['Reached Maximum Number of Iterations for ', ...
           'LIB computation without Convergence'],2)
else
  fm_disp(['Limit Induced Bifurcation computed in ', ...
           num2str(Settings.lftime),' s'],1)
  if Settings.showlf == 1, fm_stat, end
end

% restore original data
% ===========================================================================
fm_status('lib','close')

DAE.n = dynordold;
Settings.forcepq = forcepq;
PQ = restore(PQ);
PV = restore(PV);
SW = restore(SW);

SNB.init = 0;
LIB.init = 1;
CPF.init = 0;
OPF.init = 0;