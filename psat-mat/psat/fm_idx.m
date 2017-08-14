function  fm_idx(flag)
% FM_IDX define formatted and unformatted names of system variables
%
% FM_IDX(FLAG)
%   FLAG  1  -> power flow and state variables
%         2  -> determinants and eigenvalues
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    05-Mar-2004
%Update:    14-Sep-2005
%Update:    19-Dec-2005
%Version:   1.2.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Varname DAE Bus File Settings Path
global Line Ltc Phs Hvdc Lines

nL = Settings.nseries;

switch flag

 case 1  % power flow and state variables

  nidx = DAE.n+DAE.m+2*Bus.n+4*nL;

  % cell array of unformatted variable names
  Varname.uvars = cell(nidx,1);

  % cell array of formatted (LaTeX style) variable names
  Varname.fvars = cell(nidx,1);

  % state variables
  if DAE.n
    for j = 1:length(Varname.fnamex)
      eval(['global ',Varname.compx{j}]);
      nome = eval([Varname.compx{j},'.',Varname.unamex{j}]);
      if ~isempty(nome)
        b = find(nome);
        numero = length(b);
        for i = 1:numero
          Varname.uvars{nome(b(i))} = [Varname.unamex{j},'_', ...
                              Varname.compx{j},'_',  int2str(b(i))];
          Varname.fvars{nome(b(i))} = [Varname.fnamex{j},'_{', ...
                              Varname.compx{j},' ', int2str(b(i)),'}'];
        end
      end
    end
  end

  % algebraic variables
  idx1 = DAE.n+Bus.n;
  idx2 = DAE.n+DAE.m;
  idx3 = idx2+Bus.n;
  for j = 1:Bus.n
    b = strrep(Bus.names{j,1},'_',' ');
    % theta
    Varname.fvars{DAE.n+j} = [char(92),'theta_{', b,'}'];
    Varname.uvars{DAE.n+j} = ['theta_', b];
    % V
    Varname.fvars{idx1+j} = ['V_{', b,'}'];
    Varname.uvars{idx1+j} = ['V_', b];
    % P
    Varname.fvars{idx2+j} = ['P_{', b,'}'];
    Varname.uvars{idx2+j} = ['P_', b];
    % Q
    Varname.fvars{idx3+j} = ['Q_{', b,'}'];
    Varname.uvars{idx3+j} = ['Q_', b];
  end

  if DAE.m > 2*Bus.n
    for j = 1:length(Varname.fnamey)
      eval(['global ',Varname.compy{j}]);
      nome = eval([Varname.compy{j},'.',Varname.unamey{j}]);
      if ~isempty(nome)
        b = find(nome);
        numero = length(b);
        for i = 1:numero
          Varname.uvars{DAE.n+nome(b(i))} = [Varname.unamey{j},'_', ...
                              Varname.compy{j},'_',  int2str(b(i))];
          Varname.fvars{DAE.n+nome(b(i))} = [Varname.fnamey{j},'_{', ...
                              Varname.compy{j},' ', int2str(b(i)),'}'];
        end
      end
    end
  end

  fr = [Line.fr; Ltc.bus1; Phs.bus1; Hvdc.bus1; Lines.bus1];
  to = [Line.to; Ltc.bus2; Phs.bus2; Hvdc.bus2; Lines.bus2];

  idx1 = DAE.n+DAE.m+2*Bus.n;
  idx2 = idx1 + nL;
  idx3 = idx2 + nL;
  idx4 = idx3 + nL;
  idx5 = idx4 + nL;
  idx6 = idx5 + nL;
  idx7 = idx6 + nL;
  idx8 = idx7 + nL;

  for j = 1:nL
    b = Bus.names{fr(j),1};
    d = Bus.names{to(j),1};
    % P_ij
    Varname.fvars{idx1+j} = ['P_{',b,' ',d,'}'];
    Varname.uvars{idx1+j} = ['P_',b,'_',d];
    % P_ji
    Varname.fvars{idx2+j} = ['P_{',d,' ',b,'}'];
    Varname.uvars{idx2+j} = ['P_',d,'_',b];
    % Q_ij
    Varname.fvars{idx3+j} = ['Q_{',b,' ',d,'}'];
    Varname.uvars{idx3+j} = ['Q_',b,'_',d];
    % Q_ji
    Varname.fvars{idx4+j} = ['Q_{',d,' ',b,'}'];
    Varname.uvars{idx4+j} = ['Q_',d,'_',b];
    % I_ij
    Varname.fvars{idx5+j} = ['I_{',b,' ',d,'}'];
    Varname.uvars{idx5+j} = ['I_',b,'_',d];
    % I_ji
    Varname.fvars{idx6+j} = ['I_{',d,' ',b,'}'];
    Varname.uvars{idx6+j} = ['I_',d,'_',b];
    % S_ij
    Varname.fvars{idx7+j} = ['S_{',b,' ',d,'}'];
    Varname.uvars{idx7+j} = ['S_',b,'_',d];
    % S_ji
    Varname.fvars{idx8+j} = ['S_{',d,' ',b,'}'];
    Varname.uvars{idx8+j} = ['S_',d,'_',b];
  end

  Varname.nvars = length(Varname.uvars);
  % plot variables
  if isempty(Varname.idx)
    % use default variables
    Varname.fixed = 1;
    Varname.custom = 0;
    Varname.x = 1;
    Varname.y = 1;
    Varname.P = 0;
    Varname.Q = 0;
    Varname.Pij = 0;
    Varname.Qij = 0;
    Varname.Iij = 0;
    Varname.Sij = 0;
    Varname.idx = [1:(DAE.n+DAE.m)]';
  else
    % check for possible index inconsistency
    idx = find(Varname.idx > Varname.nvars);
    if ~isempty(idx)
      Varname.idx(idx) = [];
    end
  end

 case 2 % determinants and eigenvalues

  idx0 = DAE.n+DAE.m+2*Bus.n+8*nL;
  Varname.fvars{idx0+1} = 'det(A_S)';
  %Varname.fvars{idx0+2} = 'det(J_l_f)';
  %Varname.fvars{idx0+3} = 'det(J_l_f_d)';
  Varname.uvars{idx0+1} = 'det(As)';
  %Varname.uvars{idx0+2} = 'det(Jlf)';
  %Varname.uvars{idx0+3} = 'det(Jlfd)';

  %idx0 = idx0+3;
  idx0 = idx0+1;
  for i = 1:DAE.n
    Varname.fvars{idx0+i} = [char(92),'lambda', '_{As (', int2str(i),')}'];
    Varname.uvars{idx0+i} = ['eigenvalue_As', int2str(i)];
  end

%   idx0 = idx0+DAE.n;
%   for i = 1:Bus.n
%     Varname.fvars{idx0+i} = [char(92),'lambda','_{Jlfr (', int2str(i),')}'];
%     Varname.uvars{idx0+i} = ['eigenvalue_Jlfr', int2str(i)];
%   end

%   idx0 = idx0+Bus.n;
%   for i = 1:Bus.n
%     Varname.fvars{idx0+i} = [char(92),'lambda','_{Jlfdr (', int2str(i),')}'];
%     Varname.uvars{idx0+i} = ['eigenvalue_Jlfdr', int2str(i)];
%   end

  Varname.nvars = length(Varname.uvars);

end