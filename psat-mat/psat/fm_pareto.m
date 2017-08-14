function fm_pareto
% FM_PARETO determine a Pareto set of the multi-objective
%           OPF Problem
%
% FM_PARETO
%
%see also OPF structure
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    25-Feb-2003
%Version:   1.0.1
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Fig Hdl Varname File Path DAE OPF Settings Varout
global PV SW Bus Line Demand Supply Rsrv History Theme GAMS

tempo1 = clock;

if ishandle(Fig.main)
  hdl = findobj(Fig.main,'Tag','PushClose');
  set(hdl,'String','Stop');
  set(Fig.main,'UserData',1);
end

fm_disp('  ')
fm_disp('PARETO SET COMPUTATIONS')

% open status bar
fm_bar open

% -------------------------------------------------------------------------
%          Indices
% -------------------------------------------------------------------------

idx_NaN = [];
idxo = 0;
ntot = length(OPF.omega);
n_gen = PV.n+SW.n;

% resetting time vector in case of previous time simulations
Varout.t = [];

busG = double([SW.bus;PV.bus]);
[busS,idxS] = setdiff(busG,Supply.bus);
n_gen = Supply.n+length(busS);
bus_gen = [Supply.bus;busS];

if Rsrv.n
  n_s = 2*Supply.n+2*Demand.n+4*n_gen+4*Bus.n+3+4*Line.n+2*Rsrv.n;
  n_y = Supply.n+Demand.n+2*n_gen+4*Bus.n+2+Rsrv.n;
else
  n_s = 2*Supply.n+2*Demand.n+4*n_gen+4*Bus.n+2+4*Line.n;
  n_y = Supply.n+Demand.n+2*n_gen+4*Bus.n+2;
end
n0 = 1:(n_y+Bus.n);
a1 = 2*n_s + 2*Bus.n + Demand.n + Supply.n + n_gen;
n1 = a1+1:a1+2*Bus.n;

% -------------------------------------------------------------------------
%          Building OPF.varname
% -------------------------------------------------------------------------

switch OPF.flow
 case 1, flow = 'I_';
 case 2, flow = 'P_';
 case 3, flow = 'S_';
end

Lf = cellstr(num2str(Line.fr));
Lt = cellstr(num2str(Line.to));

% -------------------------------------------------------------------------
% unformatted labels
% -------------------------------------------------------------------------
Varname.uvars = fm_strjoin('theta_',Bus.names);
Varname.uvars = [Varname.uvars;fm_strjoin('V_',Bus.names)];
Varname.uvars = [Varname.uvars;fm_strjoin('Qg_',Bus.names(bus_gen))];
Varname.uvars = [Varname.uvars;fm_strjoin('PS_',Bus.names(Supply.bus))];
Varname.uvars = [Varname.uvars;fm_strjoin('PD_',Bus.names(Demand.bus))];
Varname.uvars = [Varname.uvars;fm_strjoin('thetac_',Bus.names)];
Varname.uvars = [Varname.uvars;fm_strjoin('Vc_',Bus.names)];
Varname.uvars = [Varname.uvars;{'kg_c'}];
Varname.uvars = [Varname.uvars;fm_strjoin('Qgc_',Bus.names(bus_gen))];
Varname.uvars = [Varname.uvars;{'lambda_c'}];
if Rsrv.n
  Varname.uvars = [Varname.uvars;fm_strjoin('PR_',Bus.names(Rsrv.bus))];
end
Varname.uvars = [Varname.uvars;fm_strjoin('LMP_',Bus.names)];
Varname.uvars = [Varname.uvars;fm_strjoin(flow,Lf,'-',Lt)];
Varname.uvars = [Varname.uvars;fm_strjoin(flow,Lt,'-',Lf)];
Varname.uvars = [Varname.uvars;fm_strjoin(flow,'c',Lf,'-',Lt)];
Varname.uvars = [Varname.uvars;fm_strjoin(flow,'c',Lt,'-',Lf)];
Varname.uvars = [Varname.uvars; {'TTL'}];

% -------------------------------------------------------------------------
% formatted labels
% -------------------------------------------------------------------------
Varname.fvars = fm_strjoin('\theta_{',Bus.names,'}');
Varname.fvars = [Varname.fvars;fm_strjoin('V_{',Bus.names,'}')];
Varname.fvars = [Varname.fvars;fm_strjoin('Q_{g-',Bus.names(bus_gen),'}')];
Varname.fvars = [Varname.fvars;fm_strjoin('P_{S-',Bus.names(Supply.bus),'}')];
Varname.fvars = [Varname.fvars;fm_strjoin('P_{D-',Bus.names(Demand.bus),'}')];
Varname.fvars = [Varname.fvars;fm_strjoin('\theta_{c-',Bus.names,'}')];
Varname.fvars = [Varname.fvars;fm_strjoin('V_{c-',Bus.names,'}')];
Varname.fvars = [Varname.fvars;{'k_{gc}'}];
Varname.fvars = [Varname.fvars;fm_strjoin('Q_{gc-',Bus.names(bus_gen),'}')];
Varname.fvars = [Varname.fvars;{'\lambda_c'}];
if Rsrv.n
  Varname.fvars = [Varname.fvars;fm_strjoin('P_{R-',Bus.names(Rsrv.bus),'}')];
end
Varname.fvars = [Varname.fvars;fm_strjoin('LMP_{',Bus.names,'}')];
Varname.fvars = [Varname.fvars;fm_strjoin(flow,'{',Lf,'-',Lt,'}')];
Varname.fvars = [Varname.fvars;fm_strjoin(flow,'{',Lt,'-',Lf,'}')];
Varname.fvars = [Varname.fvars;fm_strjoin(flow,'{c',Lf,'-',Lt,'}')];
Varname.fvars = [Varname.fvars;fm_strjoin(flow,'{c',Lt,'-',Lf,'}')];
Varname.fvars = [Varname.fvars; {'TTL'}];

Varout.idx = [1:length(Varname.fvars)];
Varname.idx = Varout.idx;

% -------------------------------------------------------------------------
%          Running the Pareto Set
% -------------------------------------------------------------------------

Varout.vars = zeros(ntot,n_y+Bus.n+4*Line.n+1);
OPF.wp = OPF.omega;
OPF.show = 0;
OPF.conv = 0;
idxrho = zeros(ntot,1);

lambdamax = OPF.lmax;
lambdamin = OPF.lmin;

for j = 1:ntot
  OPF.w = OPF.omega(j);
  if ishandle(Fig.main)
    if ~get(Fig.main,'UserData'), break, end
  end

  OPF.lmax = lambdamax;
  OPF.lmin = lambdamin;
  eval(OPF.fun)

  if OPF.conv == 1

    OPF.lmax = OPF.guess(2*n_s+n_y);
    OPF.lmin = OPF.guess(2*n_s+n_y)-1e-4;

    fm_disp(['Current lambda = ', num2str(OPF.lmax)])
    OPF.w = 0.00001;
    eval(OPF.fun)

    % Lagrangian Multiplier of Power Flow Equations
    rho = -OPF.guess(2*n_s+n_y+1:end-3*Bus.n)';
    if abs(rho) < 1e-3, idxrho(j) = j; end
    Varout.vars(j,n0) = [OPF.guess(2*n_s+1:end-4*Bus.n)',rho];
    [Iij,Iji] = flows(Line,OPF.flow);
    Varout.vars(j,n_y+Bus.n+1:n_y+Bus.n+2*Line.n) = [Iij',Iji'];
    y_snap = DAE.y;
    DAE.y = OPF.guess(n1);
    [Iij,Iji] = flows(Line, OPF.flow);
    Varout.vars(j,n_y+Bus.n+2*Line.n+1:n_y+Bus.n+4*Line.n) = [Iij',Iji'];
    DAE.y = y_snap;
    Varout.vars(j,end) = ...
        Settings.mva*sum(OPF.guess(2*n_s+2*Bus.n+n_gen+Supply.n+1:2*n_s+ ...
                                   2*Bus.n+Supply.n+n_gen+Demand.n));
  else
    idx_NaN = [idx_NaN, j];
  end
  idx = j/ntot;
  fm_bar([idxo,idx])
  idxo = idx;
end

OPF.wp(idx_NaN) = [];
Varout.vars(idx_NaN,:) = [];
idxrho(idx_NaN) = [];
Varout.t = OPF.wp;

if ~isempty(find(idxrho))
  for i = 2:length(idxrho)
    if idxrho(i) ~= 0 && idxrho(i) ~= length(idxrho)
      Varout.vars(idxrho(i),:) = 0.5*(Varout.vars(idxrho(i)+1,:)+ ...
                                     Varout.vars(idxrho(i)-1,:));
    end
  end
end

% -------------------------------------------------------------------------
%          Graphical settings
% -------------------------------------------------------------------------

% close status bar
fm_bar close
% plot settings
Settings.xlabel = 'weighting factor \omega';

if ishandle(Fig.main)
  set(hdl,'String','Close');
  if ~get(Fig.main,'UserData'),
    fm_disp(['Pareto Set Computation interrupted.'],1),
    return
  end
end

fm_disp(['Pareto Set Computation completed in ', ...
         num2str(etime(clock,tempo1)),' s'],1)
OPF.init = 3;
OPF.lmax = lambdamax;
OPF.lmin = lambdamin;

if ishandle(Fig.plot), fm_plotfig, end