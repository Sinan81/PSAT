function fm_eigen(type)
% FM_EIGEN compute eigenvalues of static and dynamic Jacobian
%          matrices
%
% FM_EIGEN(TYPE,REPORT)
%       TYPE     1 -> Jlfd eigenvalues
%                2 -> Jlfv eigenvalues
%                3 -> Jlf eigenvalues
%                4 -> As eigenvalues
%       REPORT   1 -> create report file
%                0 -> no report file
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    05-Mar-2004
%Version:   1.1.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global DAE Bus Settings Varname File Path
global PQ PV SW Fig Theme SSSA Line clpsat

switch type

 case 'matrix' % set matrix type

  mat = zeros(4,1);
  mat(1) = findobj(gcf,'Tag','Checkbox1');
  mat(2) = findobj(gcf,'Tag','Checkbox2');
  mat(3) = findobj(gcf,'Tag','Checkbox3');
  mat(4) = findobj(gcf,'Tag','Checkbox4');

  tplot = zeros(3,1);
  tplot(1) = findobj(gcf,'Tag','Radiobutton1');
  tplot(2) = findobj(gcf,'Tag','Radiobutton2');
  tplot(3) = findobj(gcf,'Tag','Radiobutton3');

  ca = find(mat == gcbo);
  vals = zeros(4,1);
  vals(ca) = 1;
  for i = 1:4
    set(mat(i),'Value',vals(i))
  end
  a = get(tplot(3),'Value');
  if ca == 4
    set(tplot(3),'Enable','on')
  else
    if a
      set(tplot(3),'Value',0)
      set(tplot(1),'Value',1)
      SSSA.map = 1;
    end
    set(tplot(3),'Enable','off')
  end
  if ca == 4 && SSSA.neig > DAE.n-1,
    set(findobj(Fig.eigen,'Tag','EditText1'),'String','1')
    SSSA.neig = 1;
  elseif ca < 4 && SSSA.neig > Bus.n-1,
    set(findobj(Fig.eigen,'Tag','EditText1'),'String','1')
    SSSA.neig = 1;
  end
  SSSA.matrix = ca;
  SSSA.report = [];

 case 'map' % set eigenvalue map type

  tplot = zeros(3,1);
  tplot(1) = findobj(gcf,'Tag','Radiobutton1');
  tplot(2) = findobj(gcf,'Tag','Radiobutton2');
  tplot(3) = findobj(gcf,'Tag','Radiobutton3');

  ca = find(tplot == gcbo);
  vals = zeros(3,1);
  vals(ca) = 1;
  for i = 1:3
    set(tplot(i),'Value',vals(i))
  end
  SSSA.map = find(vals);
  SSSA.report = [];

 case 'neig' % Set number of eigs to be computed

  if SSSA.matrix == 4
    amax = DAE.n;
  else
    amax = Bus.n;
  end

  number = get(gcbo,'String');
  try
    a = round(str2num(number));
    if a > 0 && a < amax
      SSSA.neig = a;
      SSSA.report = [];
    else
      set(gcbo,'String',num2str(SSSA.neig));
    end
  catch
    set(gcbo,'String',num2str(SSSA.neig));
  end

 case 'method' % Set method for eigenvalue computation

  t1 = findobj(Fig.eigen,'Tag','Radiobutton1');
  t3 = findobj(Fig.eigen,'Tag','Radiobutton2');

  a = get(gcbo,'Value');
  hedit = findobj(Fig.eigen,'Tag','EditText1');
  if a == 1
    set(hedit,'Enable','off')
    set(t3,'Enable','on')
  else
    set(hedit,'Enable','on')
    if get(t3,'Value')
      set(t3,'Value',0)
      set(t1,'Value',1)
      SSSA.map = 1;
    end
    set(t3,'Enable','off')
  end
  SSSA.method = a;
  SSSA.report = [];

 case 'runsssa'

  % check for data file
  if isempty(File.data)
    fm_disp('Set a data file before running eigenvalue analysis.',2)
    return
  end

  % check for initial power flow solution
  if ~Settings.init
    fm_disp('Solve base case power flow...')
    Settings.show = 0;
    fm_set('lf')
    Settings.show = 1;
    if ~Settings.init, return, end
  end

  if PQ.n && Settings.pq2z
    pq2z = 0;
    if clpsat.init
      pq2z = clpsat.pq2z;
    elseif Settings.donotask
      pq2z = Settings.pq2z;
    else
      uiwait(fm_choice(['Convert PQ loads to constant impedances?']))
      pq2z = Settings.ok;
    end
    if pq2z
      % convert PQ loads to shunt admittances
      PQ = pqshunt(PQ);
      % update Jacobian matrices
      fm_call('i');
    else
      % reset PQ loads to constant powers
      PQ = noshunt(PQ);
      % update Jacobian matrices
      fm_call('i');
      Settings.pq2z = 0;
      if ishandle(Fig.setting)
        set(findobj(Fig.setting,'Tag','CheckboxPQ2Z'),'Value',0)
      end
    end
  end

  uno = 0;
  tipo_mat = SSSA.matrix;
  tipo_plot = SSSA.map;
  SSSA.report = [];

  if isempty(Bus.n)
    fm_disp('No loaded system. Eigenvalue computation cannot be run.',2)
    return
  end

  % build eigenvalue names
  if (Settings.vs == 0), fm_idx(2), end

  % initialize report structures
  Header{1,1}{1,1} = 'EIGENVALUE REPORT';
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

  if tipo_mat == 4

    if DAE.n == 0
      fm_disp('No dynamic component loaded. State matrix is not defined',2)
      return
    end

    As = DAE.Fx - DAE.Fy*(DAE.Gy\DAE.Gx) - 1e-6*speye(DAE.n);
    if tipo_plot == 3
      As = (As+8*speye(DAE.n))/(As-8*speye(DAE.n));
    end

    [auto,autor,autoi,num_auto,pf] = compute_eigs(As);

    names = cellstr(fm_strjoin('Eig As #',num2str([1:num_auto]')));

    Header{2,1} = 'STATE MATRIX EIGENVALUES';
    Cols{2,1} = {'Eigevalue', 'Most Associated States', ...
                 'Real part','Imag. Part','Pseudo-Freq.','Frequency'};
    Matrix{2,1} = zeros(num_auto,4);
    Matrix{2,1}(:,[1 2]) = [autor, autoi];

    for i = 1:num_auto;
      if autoi(i) == 0
        [part, idxs] = max(pf(i,:));
        stat = Varname.uvars{idxs};
        pfrec = 0;
        frec = 0;
      else
        [part, idxs] = sort(pf(i,:));
        stat = [Varname.uvars{idxs(end)},', ',Varname.uvars{idxs(end-1)}];
        pfrec = abs(imag(auto(i))/2/3.1416);
        frec = abs(auto(i))/2/3.1416;
      end
      Rows{2,1}{i,1} = names{i};
      Rows{2,1}{i,2} = stat;
      Matrix{2,1}(i,3) = pfrec;
      Matrix{2,1}(i,4) = frec;
    end

    [uno,Header,Cols,Rows,Matrix] = ...
        write_pf(pf,DAE.n,Varname.uvars,names,Header,Cols,Rows,Matrix);

  elseif tipo_mat == 3

    Jlf = build_gy(Line);
    if DAE.m > 2*Bus.n
      x3 = 1:2*Bus.n;
      Jlf = Jlf(x3,x3);
    end
    x1 = Bus.a;
    x2 = Bus.v;
    vbus = [getbus(SW,'a');getbus(SW,'v');getbus(PV,'v')];
    Jlf(vbus,:) = 0;
    Jlf(:,vbus) = 0;
    Jlf = Jlf + sparse(vbus,vbus,999,2*Bus.n,2*Bus.n);
    Jlfptheta = Jlf(x1,x1)+1e-5*speye(Bus.n,Bus.n);
    elementinulli = find(diag(Jlfptheta == 0));
    if ~isempty(elementinulli)
      for i = 1:length(elementinulli)
        Jlfptheta(elementinulli(i),elementinulli(i)) = 1;
      end
    end
    Jlfr = Jlf(x2,x2) - Jlf(x2,x1)*(Jlfptheta\Jlf(x1,x2));

    [auto,autor,autoi,num_auto,pf] = compute_eigs(Jlfr);

    names = cellstr(fm_strjoin('Eig Jlfr #',num2str([1:num_auto]')));

    Header{2,1} = 'EIGENVALUES OF THE STANDARD POWER JACOBIAN MATRIX';
    Cols{2,1} = {'Eigevalue', 'Most Associated Bus', 'Real part', ...
                 'Imaginary Part'};
    Rows{2,1} = names;
    Matrix{2,1} = [autor, autoi];

    for i = 1:num_auto;
      if autoi(i) == 0
        [part, idxs] = max(pf(i,:));
        stat = Bus.names{idxs};
      else
        [part, idxs] = sort(pf(i,:));
        stat = [Bus.names{idxs(end)},', ',Bus.names{idxs(end-1)}];
      end
      Rows{2,1}{i,1} = names{i};
      Rows{2,1}{i,2} = stat;
    end

    [uno,Header,Cols,Rows,Matrix] = ...
        write_pf(pf,Bus.n,Bus.names,names,Header,Cols,Rows,Matrix);

  elseif tipo_mat == 2

    x1 = Bus.a;
    x2 = Bus.v;
    if DAE.m > 2*Bus.n
      x3 = 1:2*Bus.n;
      x4 = 2*Bus.n+1:DAE.m;
      Gy = DAE.Gy(x3,x3)-DAE.Gy(x3,x4)*(DAE.Gy(x4,x4)\DAE.Gy(x4,x3));
    else
      Gy = DAE.Gy;
    end
    Jlfvr = Gy(x2,x2)-Gy(x2,x1)*(Gy(x1,x1)\Gy(x1,x2));
    vbus = [getbus(SW);getbus(PV)];
    Jlfvr = Jlfvr + sparse(vbus,vbus,998,Bus.n,Bus.n);

    [auto,autor,autoi,num_auto,pf] = compute_eigs(Jlfvr);

    names = cellstr(fm_strjoin('Eig Jlfv #',num2str([1:num_auto]')));

    Header{2,1} = 'EIGENVALUES OF THE COMPLETE POWER JACOBIAN MATRIX';
    Cols{2,1} = {'Eigevalue', 'Most Associated Bus', 'Real part', ...
                   'Imaginary Part'};
    Rows{2,1} = names;
    Matrix{2,1} = [autor, autoi];

    for i = 1:num_auto;
      if autoi(i) == 0
        [part, idxs] = max(pf(i,:));
        stat = Bus.names{idxs};
      else
        [part, idxs] = sort(pf(i,:));
        stat = [Bus.names{idxs(end)},', ',Bus.names{idxs(end-1)}];
      end
      Rows{2,1}{i,1} = names{i};
      Rows{2,1}{i,2} = stat;
    end

    [uno,Header,Cols,Rows,Matrix] = ...
        write_pf(pf,Bus.n,Bus.names,names,Header,Cols,Rows,Matrix);

  elseif tipo_mat ==  1

    if DAE.n == 0
      fm_disp('Since no dynamic component is loaded, Jlfd = Jlfv.',2)
    end

    if DAE.m > 2*Bus.n
      x3 = 1:2*Bus.n;
      x4 = 2*Bus.n+1:DAE.m;
      x5 = 1:DAE.n;
      Gy = DAE.Gy(x3,x3)-DAE.Gy(x3,x4)*(DAE.Gy(x4,x4)\DAE.Gy(x4,x3));
      Gx = DAE.Gx(x3,x5)-DAE.Gy(x3,x4)*(DAE.Gy(x4,x4)\DAE.Gx(x4,x5));
      Fx = DAE.Fx(x5,x5)-DAE.Fy(x5,x4)*(DAE.Gy(x4,x4)\DAE.Gx(x4,x5));
      Fy = DAE.Fy(x5,x3)-DAE.Fy(x5,x4)*(DAE.Gy(x4,x4)\DAE.Gy(x4,x3));
    else
      Gy = DAE.Gy;
      Gx = DAE.Gx;
      Fx = DAE.Fx;
      Fy = DAE.Fy;
    end

    Fx = Fx-1e-5*speye(DAE.n,DAE.n);
    Jlfd = Gy-Gx*(Fx\Fy);

    x1 = Bus.a;
    x2 = Bus.v;
    Jlfdr = Jlfd(x2,x2)-Jlfd(x2,x1)*(Jlfd(x1,x1)\Jlfd(x1,x2));
    vbus = [getbus(SW);getbus(PV)];
    Jlfdr = Jlfdr + sparse(vbus,vbus,998,Bus.n,Bus.n);

    [auto,autor,autoi,num_auto,pf] = compute_eigs(Jlfdr);

    names = cellstr(fm_strjoin('Eig Jlfd #',num2str([1:num_auto]')));

    Header{2,1} = 'EIGENVALUES OF THE DYNAMIC POWER JACOBIAN MATRIX';
    Cols{2,1} = {'Eigevalue', 'Most Associated Bus', 'Real part', ...
                 'Imaginary Part'};
    Rows{2,1} = names;
    Matrix{2,1} = [autor, autoi];

    for i = 1:num_auto;
      if autoi(i) == 0
        [part, idxs] = max(pf(i,:));
        stat = Bus.names{idxs};
      else
        [part, idxs] = sort(pf(i,:));
        stat = [Bus.names{idxs(end)},', ',Bus.names{idxs(end-1)}];
      end
      Rows{2,1}{i,1} = names{i};
      Rows{2,1}{i,2} = stat;
    end

    [uno,Header,Cols,Rows,Matrix] = ...
        write_pf(pf,Bus.n,Bus.names,names,Header,Cols,Rows,Matrix);

  end

  auto_neg  = find(autor < 0);
  auto_pos  = find(autor > 0);
  auto_real = find(autoi == 0);
  auto_comp = find(autoi < 0);
  auto_zero = find(autor == 0);

  num_neg  = length(auto_neg);
  num_pos  = length(auto_pos);
  num_real = length(auto_real);
  num_comp=length(auto_comp);
  num_zero = length(auto_zero);

  if ishandle(Fig.eigen)

    hdl = zeros(8,1);
    hdl(1) = findobj(Fig.eigen,'Tag','Text3');
    hdl(2) = findobj(Fig.eigen,'Tag','Text4');
    hdl(3) = findobj(Fig.eigen,'Tag','Text5');
    hdl(4) = findobj(Fig.eigen,'Tag','Text6');
    hdl(5) = findobj(Fig.eigen,'Tag','Axes1');
    hdl(6) = findobj(Fig.eigen,'Tag','Listbox1');
    hdl(7) = findobj(Fig.eigen,'Tag','Text1');
    hdl(8) = findobj(Fig.eigen,'Tag','Text2');

    set(hdl(1),'String',num2str(num_pos));
    set(hdl(2),'String',num2str(num_neg));
    set(hdl(3),'String',num2str(num_comp));
    set(hdl(4),'String',num2str(num_zero));
    set(hdl(7),'String',num2str(DAE.n));
    set(hdl(8),'String',num2str(Bus.n));

    autovalori = cell(length(autor),1);
    if num_auto < 10
      d = '';
      e = '';
    elseif num_auto < 100
      d = ' ';
      e = '';
    elseif num_auto < 1000
      d = ' ';
      e = ' ';
    else
      d = ' ';
      e = '  ';
    end
    for i = 1:length(autor)
      if autor(i)>=0
        a = ' ';
      else
        a = '';
      end
      if autoi(i)>=0
        c = '+';
      else
        c = '-';
      end
      if i < 10
        f1 = [d,e];
      elseif i < 100
        f1 = e;
      else
        f1 = '';
      end
      if tipo_plot == 3
        autovalori{i,1} = ['|',char(181),'(A)| #',num2str(i), ...
                           f1, ' ', fvar(abs(auto(i)),9)];
      else
        autovalori{i,1} = [char(181),'(A) #',num2str(i),f1, ...
                           ' ',a,num2str(autor(i)),' ',c, ...
                           ' j',num2str(abs(autoi(i)))];
      end
    end
    set(hdl(6),'String',autovalori,'Value',1)
  end

  Header{3+uno,1} = 'STATISTICS';
  Cols{3+uno} = '';
  Rows{3+uno} = '';
  Matrix{3+uno,1} = [];

  if tipo_mat < 4
    Rows{3+uno}{1,1} = 'NUMBER OF BUSES';
    Matrix{3+uno,1}(1,1) = Bus.n;
  else
    Rows{3+uno}{1,1} = 'DYNAMIC ORDER';
    Matrix{3+uno,1}(1,1) = DAE.n;
  end
  Rows{3+uno}{2,1} = '# OF EIGS WITH Re(mu) < 0';
  Matrix{3+uno,1}(2,1) = num_neg;
  Rows{3+uno}{3,1} = '# OF EIGS WITH Re(mu) > 0';
  Matrix{3+uno,1}(3,1) = num_pos;
  Rows{3+uno}{4,1} = '# OF REAL EIGS';
  Matrix{3+uno,1}(4,1) = num_real;
  Rows{3+uno}{5,1} = '# OF COMPLEX PAIRS';
  Matrix{3+uno,1}(5,1) = num_comp;
  Rows{3+uno}{6,1} = '# OF ZERO EIGS';
  Matrix{3+uno,1}(6,1) = num_zero;

  % save eigenvalues and participation factors in SSSA structure
  SSSA.eigs = auto;
  SSSA.pf = pf;

  if ishandle(Fig.eigen), axes(hdl(5)); fm_eigen('graph')
  end

  SSSA.report.Matrix = Matrix;
  SSSA.report.Header = Header;
  SSSA.report.Cols = Cols;
  SSSA.report.Rows = Rows;

 case 'report'

  if SSSA.matrix == 4 && DAE.n == 0
    fm_disp('No dynamic component loaded. State matrix is not defined',2)
    return
  end

  if isempty(SSSA.report), fm_eigen('runsssa'), end

  % writing data...
  fm_write(SSSA.report.Matrix,SSSA.report.Header, ...
           SSSA.report.Cols,SSSA.report.Rows)

 case 'graph'

  hgca = gca;

  if isempty(SSSA.eigs)
    fm_eigen('runsssa')
  end

  axes(hgca)
  autor = real(SSSA.eigs);
  autoi = imag(SSSA.eigs);
  num_auto = length(SSSA.eigs);
  idx = find(autor > -990);
  if ~isempty(idx)
    autor = autor(idx);
    autoi = autoi(idx);
  end

  if ishandle(Fig.eigen)
    switch SSSA.map
     case 1
      idxn = find(autor < 0);
      idxz = find(autor == 0);
      idxp = find(autor > 0);
      if SSSA.matrix == 4
        hdle = plot(autor(idxn), autoi(idxn),'bx', ...
                    autor(idxz), autoi(idxz),'go', ...
                    autor(idxp), autoi(idxp),'rx');
      else
        hdle = plot(autor(idxn), autoi(idxn),'rx', ...
                    autor(idxz), autoi(idxz),'go', ...
                    autor(idxp), autoi(idxp),'bx');
      end
      hold on
      plot([0,0],ylim,':k');
      plot(xlim,[0,0],':k');
      zeta = [0.05, 0.1, 0.15];
      colo = {'r:', 'g:', 'b:'};
      for i = 1:3
        mu = sqrt((1 - zeta(i)^2)/zeta(i)^2);
        ylimits = ylim;
        plot([0, -ylimits(2)/mu], [0, ylimits(2)], colo{i})
        plot([0, ylimits(1)/mu], [0, ylimits(1)], colo{i})
      end
      set(hdle,'MarkerSize',8);
      xlabel('Real');
      ylabel('Imag');
      hold off
      set(hgca,'Tag','Axes1')
     case 2
      surf(real(SSSA.pf))
      set(hgca,'XLim',[1 num_auto],'YLim',[1 num_auto]);
      view(0,90);
      box('on')
      ylabel('Eigenvalues');
      if SSSA.matrix == 4
        xlabel('State Variables');
      else
        xlabel('Buses');
      end
      shading('interp')
      colormap('summer');
      title('Participation Factors')
      set(hgca,'Tag','Axes1');
     case 3
      t = 0:0.01:2*pi+0.01;
      x = cos(t);
      y = sin(t);
      plot(x,y,'k:')
      hold on
      idxn = find(autor < 1);
      idxz = find(autor == 1);
      idxp = find(autor > 1);
      hdle = plot(autor(idxn), autoi(idxn),'bx', ...
                  autor(idxz), autoi(idxz),'go', ...
                  autor(idxp), autoi(idxp),'rx');
      set(hdle,'MarkerSize',8);
      xlabel('Real');
      ylabel('Imag');
      xlim(1.1*xlim);
      ylim(1.1*ylim);
      plot([0,0],1.1*ylim,':k');
      plot(1.1*xlim,[0,0],':k');
      hold off
      set(hgca,'Tag','Axes1');
    end
    set(hgca,'Color',Theme.color11)
  end

end

% =======================================================
function [auto,autor,autoi,num_auto,pf] = compute_eigs(A)

global Settings SSSA

meth = {'LM';'SM';'LR';'SR';'LI';'SI'};
neig = SSSA.neig;
opts = SSSA.method-1;
opt.disp = 0;

if opts
  [V, auto] = eigs(A,neig,meth{opts},opt);
  [W, dummy] = eigs(A',neig,meth{opts},opt);
else
  [V, auto] = eig(full(A));
  W = [pinv(V)]';
end

auto = diag(auto);
auto = round(auto/Settings.lftol)*Settings.lftol;
num_auto = length(auto);
autor = real(auto);
autoi = imag(auto);

WtV = sum(abs(W).*abs(V));
pf = [abs(W).*abs(V)]';
%pf = [W.*V].';  % for getting p.f. with their signs
for i = 1:length(auto), pf(i,:) = pf(i,:)/WtV(i); end

% =======================================================
function [uno,Header,Cols,Rows,Matrix] = write_pf(pf,n,name1,name2,Header,Cols,Rows,Matrix)

uno = fix(n/5);
due = rem(n,5);
if due > 0, uno = uno + 1; end
for k = 1:uno
  Header{2+k,1} = 'PARTICIPATION FACTORS (Euclidean norm)';
  Cols{2+k} = {'  ',name1{5*(k-1)+1:min(5*k,n)}};
  Rows{2+k} = name2;
  Matrix{2+k,1} = pf(:,5*(k-1)+1:min(5*k,n));
end