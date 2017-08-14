function Pout = fm_n1cont
% FM_N1CONT compute power limits in transmission lines
%           with an N-1 contingency criterion
%
%PMAX = FM_N1CONT (output stored in CPF.pmax)
%
%see also FM_SNB
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    05-July-2004
%Version:   1.1.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
%Copyright (C) 2002-2016 Federico Milano

fm_var

if ~autorun('(N-1) Contingency Analysis',0)
  return
end

fm_disp
fm_disp('N-1 Contingency Computation')

tempo1 = clock;
Settings.show = 0;
fm_set('lf')

CPFold = CPF;
CPF.show = 0;
length(Snapshot.y);

% Continuation Power Flow settings
% ------------------------------------------------------------------

CPF.method = 1;
CPF.flow = 1;
CPF.type = 3;
CPF.sbus = 0;
CPF.vlim = 1;
CPF.ilim = 1;
CPF.qlim = 1;
CPF.linit = 0;

% ==================================================================
% Finding "antennas", i.e. buses that are connected to the network
% through a single line
% ==================================================================

[antennas,fromto] = findantennas(Line);

fm_disp
if ishandle(Fig.main)
  if ishandle(Hdl.status)
    delete(Hdl.status);
    Hdl.status = -1;
  end
  hdl = findobj(Fig.main,'Tag','PushClose');
  set(hdl,'String','Stop')
  set(Fig.main,'UserData',1)
end
sp = ' * ';

% ====================================================================
% Saving complete impedance matrix and voltages
% ====================================================================

idx_old = 0;
yold = DAE.y;

% ====================================================================
% Continuation Power Flow loop for the (N-1) contingency evaluations
% ====================================================================

lcrit = [];

fm_disp('Continuation Power Flow Computations')

[Fijbc,Fjibc] = flows(Line,'active');
Pbase = max(Fijbc,Fjibc);
[Fijbc,Fjibc] = flows(Line,'apparent');
Sbase = max(Fijbc,Fjibc);
lcrit = zeros(Line.n,2);
Pij = zeros(Line.n,Line.n);
Pji = zeros(Line.n,Line.n);
Sij = zeros(Line.n,Line.n);
Sji = zeros(Line.n,Line.n);

% (N-1) contingency analysis
for i = 1:Line.n
  if ishandle(Fig.main)
    if ~get(Fig.main,'UserData'), break, end
  end
  SW = restore(SW);
  PV = restore(PV);
  PQ = restore(PQ);
  Demand = restore(Demand);
  Supply = restore(Supply);

  idx = find(fromto == i);

  if ~isempty(idx)

    idx_sw = findbus(SW,antennas(idx));
    idx_pv = findbus(PV,antennas(idx));
    idx_pq = findbus(PQ,antennas(idx));
    idx_de = findbus(Demand,antennas(idx));
    idx_su = findbus(Supply,antennas(idx));

    SW = remove(SW,idx_sw);
    if ~isempty(idx_sw), SW = add(SW,move2sw(PV)); end
    PV = remove(PV,idx_pv);
    PQ = remove(PQ,idx_pq,'force');
    Demand = remove(Demand,idx_de);
    Supply = remove(Supply,idx_su);

  end

  fm_disp(['Line #',fvar(i,4)])
  fm_disp([sp,'from ',fvar(Bus.names{Line.fr(i)},12),' to ', ...
	   fvar(Bus.names{Line.to(i)},12)])

  % set line outage
  status = Line.u(i);
  Line = setstatus(Line,i,0);

  a = [];
  guess = 0;

  while isempty(a)
    if guess > 20, break, end
    DAE.y = yold;
    DAE.x = Snapshot(1).x;
    CPF.init = 0;
    a = fm_cpf('n1cont');
    CPF.linit = CPF.linit-0.1;
    guess = guess + 1;
  end

  CPF.linit = 0;

  if ~isempty(a) && ~isempty(DAE.y) && abs(a-CPF.linit) > 1e-4
    lcrit(i,:) = [a,1];
    % active power flows in transmission lines
    [Fij,Fji] = flows(Line,'active');
    % take out the power flow in the line with contingency
    Fij(i) = NaN;
    Fji(i) = NaN;
    Fij(find(abs(Fij) < 1e-6)) = NaN;
    Fji(find(abs(Fji) < 1e-6)) = NaN;
    Pij(:,i) = abs(real(Fij));
    Pji(:,i) = abs(real(Fji));
    % apparent power flows in transmission lines
    [Fij,Fji] = flows(Line,'apparent');
    % take out the power flow in the line with contingency
    Fij(i) = NaN;
    Fji(i) = NaN;
    Fij(find(abs(Fij) < 1e-6)) = NaN;
    Fji(find(abs(Fji) < 1e-6)) = NaN;
    Sij(:,i) = abs(real(Fij));
    Sji(:,i) = abs(real(Fji));
  else
    lcrit(i,:) = [NaN,0];
    Pij(:,i) = NaN*zeros(Line.n,1);
    Pji(:,i) = NaN*zeros(Line.n,1);
    Sij(:,i) = NaN*zeros(Line.n,1);
    Sji(:,i) = NaN*zeros(Line.n,1);
  end
  fm_disp([sp,'ATC = ', num2str(lcrit(i,1))])

  % reset line outage
  Line.u(i) = status;

end

Pmax = min(Pij',Pji');
if nargout == 1, Pout = Pmax; end
[Pmax, Pidx] = min(Pmax);

Smax = min(Sij',Sji');
[Smax, Sidx] = min(Smax);

Header{1,1}{1,1} = 'N-1 CONTINGENCY ANALYSIS';
Header{1,1}{2,1} = ' ';
Header{1,1}{3,1} = ['P S A T  ',Settings.version];
Header{1,1}{4,1} = ' ';
Header{1,1}{5,1} = 'Author:  Federico Milano, (c) 2002-2016';
Header{1,1}{6,1} = 'e-mail:  federico.milano@ucd.ie';
Header{1,1}{7,1} = 'website: faraday1.ucd.ie/psat.html';
Header{1,1}{8,1} = ' ';
Header{1,1}{9,1} = ['File:  ', Path.data,strrep(File.data,'(mdl)','.mdl')];
Header{1,1}{10,1} = ['Date:  ',datestr(now,0)];

Matrix{1,1} = [];
Cols{1,1} = '';
Rows{1,1} = '';

Header{2,1} = 'POWER FLOW LIMITS';
Cols{2,1} = {' Line',' Outage of', ' Worst case',' Pij base',' Pij max',' Sij base',' Sij max'; ...
             ' ',' this line',' line outage',' [p.u.]',' [p.u.]',' [p.u.]',' [p.u.]'};
for i = 1:Line.n
  Rows{2,1}{i,1} = [num2str(getidx(Bus,Line.fr(i))),'-', ...
                    num2str(getidx(Bus,Line.to(i)))];
  Rows{2,1}{i,3} = [num2str(getidx(Bus,Line.fr(Pidx(i)))),'-', ...
                    num2str(getidx(Bus,Line.to(Pidx(i))))];
  if lcrit(i,2)
    Rows{2,1}{i,2} = ' Feasible';
  else
    Rows{2,1}{i,2} = ' Unfeasible';
  end
end
Matrix{2,1} = [Pbase,Pmax',Sbase,Smax'];

% writing data...
fm_write(Matrix,Header,Cols,Rows)

if ishandle(Fig.main), set(hdl,'String','Close'), end
Settings.show = 1;

% restore components
CPF = CPFold;
Line = build_y(Line);
islands(Line)
SW = restore(SW);
PV = restore(PV);
PQ = restore(PQ);
Demand = restore(Demand);
Supply = restore(Supply);

CPF.pmax = Pmax';
CPF.smax = Smax';
CPF.init = 3;

if ishandle(Fig.main)
  if ~get(Fig.main,'UserData'),
    fm_disp('N-1 contingency computation interrupted.')
  else
    fm_disp(['N-1 contingency computation completed in ', ...
             num2str(etime(clock,tempo1)),' s'])
  end
else
  fm_disp(['N-1 contingency computation completed in ', ...
           num2str(etime(clock,tempo1)),' s'])
end