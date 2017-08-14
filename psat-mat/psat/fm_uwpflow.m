function varargout = fm_uwpflow(varargin)
% FM_UWPFLOW PSAT/UWPFLOW interface function.
%
% FM_UWPFLOW run UWPFLOW using current settings
%
% FM_UWPFLOW(OPTION)
%     OPTION:  'init' initialise UWPFLOW.opt structure
%
%
%see UWPFLOW structure for settings
%
%Author:    Federico Milano
%Date:      01-May-2003
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global UWPFLOW DAE Bus Settings clpsat
global Fig File Path History Hdl
global Supply Demand PQ SW PV

if ~nargin, return, end

switch varargin{1}
 case 'init'

  if ~isempty(UWPFLOW.opt), return, end

  % ----------------------------------------------------------------- %
  %                                                                   %
  %   Legend:                                                         %
  %                                                                   %
  %    1 -a    2 -A    3 -b    4 -B    5 -c    6 -C    7 -d    8 -D   %
  %    9 -e   10 -E   11 -f   12 -F   13 -g   14 -G   15 -h   16 -H   %
  %   17 -i   18 -I   19 -j   20 -J   21 -k   22 -K   23 -l   24 -L   %
  %   25 -m   26 -M   27 -n   28 -N   29 -o   30 -O   31 -p   32 -P   %
  %   33 -q   34 -qx  35 -qz  36 -Q   37 -QX  38 -r   39 -R   40 -s   %
  %   41 -S   42 -t   43 -T   44 -u   45 -U   46 -v   47 -V   48 -w   %
  %   49 -W   50 -x   51 -X   52 -y   53 -Y   54 -z   55 -Z   56 -0   %
  %   57 -1   58 -2   59 -3   60 -4   61 -5   62 -6   63 -7   64 -8   %
  %   65 -9   66 -$   67 -#                                           %
  %                                                                   %
  % ----------------------------------------------------------------- %

  UWPFLOW.opt = ...
      struct('a', [], 'A', [], 'b', [], 'B', [], 'c', [], 'C', [], ...
             'd', [], 'D', [], 'e', [], 'E', [], 'f', [], 'F', [], ...
             'g', [], 'G', [], 'h', [], 'H', [], 'i', [], 'I', [], ...
             'j', [], 'J', [], 'k', [], 'K', [], 'l', [], 'L', [], ...
             'm', [], 'M', [], 'n', [], 'N', [], 'o', [], 'O', [], ...
             'p', [], 'P', [], 'q', [], 'qx',[], 'qz',[], 'Q', [], ...
             'QX',[], 'r', [], 'R', [], 's', [], 'S', [], 't', [], ...
             'T', [], 'u', [], 'U', [], 'v', [], 'V', [], 'w', [], ...
             'W', [], 'x', [], 'X', [], 'y', [], 'Y', [], 'z', [], ...
             'Z', [], ...
             'zero',  [], ...
             'one',   [], ...
             'two',   [], ...
             'three', [], ...
             'four',  [], ...
             'five',  [], ...
             'six',   [], ...
             'seven', [], ...
             'eight', [], ...
             'nine',  [], ...
             'dollar',[], ...
             'bound', []);

  fields = fieldnames(UWPFLOW.opt);
  status = logical(zeros(length(fields),1));
  values = zeros(length(fields),1);
  extens = cell(length(fields),1);

  %status([4,12,29,42]) = ~status([4,12,29,42]);
  values([4,11,12,21,24,29,30,41,42,44,45,46,54,57,58]) = ...
      [1,1,0.01,1,1e-8,0.000001,6,1,0.1,1e-3,10,1,50,1,5]';

  extens{22} = '.k';   % -K option
  extens{52} = '.w';   % -y option
  extens{53} = '.v';   % -Y option
  extens{17} = '.vp';  % -i option
  extens{23} = '.log'; % -l option
  extens{48} = '.cf';  % -w option
  extens{49} = '.cf';  % -W option
  extens{47} = '.ini'; % -V option
  extens{5}  = '.cpf'; % -c option
  extens{6}  = '.cpf'; % -C option
  extens{8}  = '.oh';  % -D option
  extens{59} = '.gen'; % -3 option
  extens{10} = '.poc'; % -E option
  extens{55} = '.ntv'; % -Z option

  for i = 1:length(fields)
    optnum = {'zero', 'one', 'two', 'three', 'four', ...
              'five', 'six', 'seven', 'eight', 'nine'};
    idxnum = strmatch(fields{i},optnum,'exact');
    if idxnum,
      name = num2str(idxnum-1);
    elseif strcmp(fields{i},'bound')
      name = '#';
    elseif strcmp(fields{i},'dollar')
      name = '$';
    else
      name = fields{i};
    end
    if values(i)
      value = values(i);
    else
      value = [];
    end
    UWPFLOW.opt = setfield( ...
        UWPFLOW.opt,fields{i}, ...
        struct('status',status(i),'name',['-',name], ...
               'num',value,'ext',extens{i}));
  end

 case 'methods' % [-c], [-C] and [-H] options

  value = get(gcbo,'Value');
  UWPFLOW.method = value;

  switch value
   case 1 % power flow

    UWPFLOW.opt.c.status = 0;
    UWPFLOW.opt.C.status = 0;
    UWPFLOW.opt.H.status = 0;

   case 2 % continuation method

    UWPFLOW.opt.c.status = 1;
    UWPFLOW.opt.C.status = 0;
    UWPFLOW.opt.H.status = 0;

   case 3 % direct method

    UWPFLOW.opt.c.status = 0;
    UWPFLOW.opt.C.status = 1;
    UWPFLOW.opt.H.status = 0;

   case 4 % parameterized continuation method

    UWPFLOW.opt.c.status = 0;
    UWPFLOW.opt.C.status = 0;
    UWPFLOW.opt.H.status = 1;

  end

 case 'filename'

  string = fm_input('File name:', ...
                    'UWPFLOW Input/Output File Name',1,{UWPFLOW.file});
  if isempty(string), return, end
  if ~isempty(string{1})
    UWPFLOW.file = string{1};
    output = {'.k';   '.v';   '.w';   '.pf'; '.jac'; '.cf'; '.cpf';
              '.mis'; '.var'; '.log'; '.oh'; '.vp'; '.gen'; '.ini';
              '.poc'; '.ntv'};
    output = fm_strjoin(UWPFLOW.file,output);
    hdl = findobj(Fig.uwpflow,'Tag','PopupUWFile');
    set(hdl,'String',output)
  end

 case 'uwrun'

  [u,w] = system('uwpflow');
  if isempty(strmatch('UW Continuation Power Flow',w))
    uiwait(fm_choice('UWPFLOW is not properly installed on your system.',2))
    return
  end

  % check for file data
  if isempty(File.data)
    fm_disp(['Load file data before running PSAT-UWPFLOW ' ...
             'interface.'])
    return
  end

  % create IEEE CDF file
  file = strrep(File.data,'(mdl)','_mdl');
  file = strrep(file,'@ ','');
  check = psat2ieee([file,'.m'],Path.data);
  if ~check
    fm_disp(['Something wrong when converting data file in IEEE ' ...
             'CDF'])
    return
  end

  % create UWPFLOW command line
  uwcom = fm_uwpflow('makecom',1);
  if isempty(uwcom), return, end

  if ~isempty(UWPFLOW.command) && clpsat.init
    uwcom = UWPFLOW.command;
  end

  if ~strcmp(UWPFLOW.command,uwcom) && ~isempty(UWPFLOW.command)
    uiwait(fm_choice(['User defined UWPFLOW command differs from current ' ...
               'settings. Use custom UWPFLOW command?']))
    if Settings.ok, uwcom = UWPFLOW.command; end
  end

  % Current solution is stored in a IEEE CDF file
  if isempty(findstr(uwcom,'-W'))
    fm_disp(['System results are stored in "',UWPFLOW.file, ...
             '.cf" (IEEE TAPE format).'])
    uwcom = [uwcom, ' -W',UWPFLOW.file,'.cf'];
  end

  % Jacobian, variables and equation mismatches of the current solution
  if ~isempty(findstr(uwcom,'-j'))
    uwcom = strrep(uwcom,'-j','-J');
  end
  if isempty(findstr(uwcom,'-J'))
    uwcom = [uwcom, ' -J',UWPFLOW.file];
  end
  fm_disp(['System Jacobian, variables and mismatches are stored ' ...
           'in:'])
  fm_disp([UWPFLOW.file,'.jac, ',UWPFLOW.file,'.var, and ', ...
           UWPFLOW.file,'.mis files.'])

  % write psatuw.k file, if needed
  copt = UWPFLOW.opt.c.status;
  Copt = UWPFLOW.opt.C.status;
  Bopt = UWPFLOW.opt.B.status;
  Hopt = UWPFLOW.opt.H.status;
  vopt = UWPFLOW.opt.v.status;
  if copt || Copt || Bopt || Hopt || vopt
    linef = '%5d    %5d         %8.5f %8.5f %8.5f %5d %5d %8.5f %8.5f\n';
    fid = fopen([Path.data,UWPFLOW.file,'.k'],'wt');
    if fid == -1
      fm_disp(['Could not create file ''psatuw.k'' for power ' ...
               'directions.'],2)
      return
    end
    count = fprintf(fid,'C %5d BUS AC TEST SYSTEM \n',Bus.n);
    count = fprintf(fid,'C Generation and Load Directions \nC \n');
    count = fprintf(fid,['C This file contains the generation (DPg) ' ...
                        'and load (Pnl, Qnl, and optional\n']);
    count = fprintf(fid,['C Pzl and Qzl) direction, and the maximum P ' ...
                        'generation (PgMax) needed for \n']);
    count = fprintf(fid,['C finding the bifurcation point.  Since the ' ...
                        'IEEE Common Format does not\n']);
    count = fprintf(fid,['C allow for the definition of PgMax, this value ' ...
                        'is ignored in this file\n']);
    count = fprintf(fid,'C by making it equal to 0.\nC \n');
    count = fprintf(fid,['C The file must be read with the -K option ' ...
                        'whenever one wants to do\n']);
    count = fprintf(fid,['C bifurcation studies (-c, -C, -H and -B ' ...
                        'options).\n']);
    count = fprintf(fid,['C The unformatted data is given in the ', ...
                        'following order:\nC \n']);
    count = fprintf(fid,['C BusNumber  BusName    DPg      Pnl      ' ...
                        'Qnl      PgMax [ Smax Vmax Vmin Pzl  Qzl ]\n']);

    [Vmax,Vmin] = fm_vlim(1.2,0.8);

    for i = 1:Bus.n

      idxSu = findbus(Supply,i);
      idxDe = findbus(Demand,i);
      idxSw = findbus(SW,i);
      idxPv = findbus(PV,i);
      idxPq = findbus(PQ,i);

      % Generator Active Power direction (DPg)
      if Supply.n
        DPg = getpg(Supply,idxSu);
      else % if no Supply, use base case powers
        DPg = getpg(SW,idxSw)+getpg(PV,idxPv);
      end

      % Load Power Directions (Pnl,Qnl)
      if Demand.n
        [Pnl,Qnl] = pqdir(Demand,idxDe);
      else % if no Demand, use base case powers
        [Pnl,Qnl] = pqdir(PQ,idxPq);
      end

      count = fprintf(fid,linef,getidx(Bus,i),0,DPg,Pnl,Qnl,0, ...
                      0,Vmax(i),Vmin(i));
    end
    count = fclose(fid);
  end

  % run UWPFLOW
  cd(Path.data)
  [status,result] = system(uwcom);
  cd(Path.local)
  if status == 2
    fm_disp(['Something wrong in the execution of UWPFLOW. Check ' ...
             'options.'])
    return
  else
    fm_disp('UWPFLOW computations completed.')
  end

  % load and plot nose curves
  if findstr(uwcom,[UWPFLOW.file,'.cpf'])
    fid = fopen([Path.data,UWPFLOW.file,'.cpf'],'rt');
    output = [];
    if fid == -1
      fm_disp(['Could not open file ''',UWPFLOW.file, ...
               '.cpf'' for loading nose curves.'])
    else
      row = fgetl(fid);
      if row == -1
        fm_disp(['* * * The file ',UWPFLOW.file, ...
                 '.cpf is empty * * *'])
        return
      end
      pattern = [char(92),'w*',char(92),'.*', ...
                 char(92),'w*',char(92),'.*'];
      b = [1,findstr(row,'V')];
      c = b+3;
      names = cell(length(b)-1,1);
      for i = 2:length(b)
        volts{i-1} = row([b(i):c(i)]);
      end
      while 1
        row = fgetl(fid);
        if row == -1, break, end
        output = [output; str2num(row)];
      end
      count = fclose(fid);
    end
    % plot continuation curves
    if ~clpsat.init
      figure
      plot(output(:,1),output(:,2:end))
      legend(volts)
      if Settings.hostver >= 7, legend(gca,'boxoff'), end
      xlabel('Loading Factor')
      ylabel('Voltages')
    end
  end

  % read UWPFLOW output and import results in PSAT
  if isempty(findstr(uwcom,[UWPFLOW.file,'.cf'])) || ...
        ~isempty(findstr(uwcom,[UWPFLOW.file,'.cpf']))
    return
  end

  if ~clpsat.init
    Settings.ok = 0;
    uiwait(fm_choice('Do you want to load UWPFLOW solution to PSAT?'))
    if ~Settings.ok
      return
    end
  end

  fm_disp('Read from IEEE Common Data Format...');
  fm_disp(['Source data file "',UWPFLOW.file,'.cf"'])

  fid = fopen([Path.data,UWPFLOW.file,'.cf']);
  if fid == -1,
    fm_disp(['Can''t open file ',Path.data,UWPFLOW.file,'.cf'],2),
    return
  end

  % skip the first two rows ...
  foo = fgetl(fid);
  foo = fgetl(fid); % headings ...

  % get the number of buses
  row = fgetl(fid);
  idx = findstr(row,' ITEMS');
  busnum = str2num(row(17:idx-1));
  bus = zeros(busnum,7);

  for i = 1:busnum
    row = fgetl(fid);
    if row == -1
      fm_disp(['Bus Data abnormally terminated. ', ...
      'Conversion Process Interrupted'],2);
      fclose(fid);
      return
    end
    bus(i,1) = str2num(row(1:4));   % bus #
    bus(i,2) = str2num(row(28:33)); % voltage
    bus(i,3) = str2num(row(34:40)); % angle
    bus(i,4) = str2num(row(60:67)); % generation P
    bus(i,5) = str2num(row(68:75)); % generation Q
    bus(i,6) = str2num(row(41:49)); % load P
    bus(i,7) = str2num(row(50:59)); % load Q
  end

  fclose(fid);

  bus(:,4:7) = bus(:,4:7)/Settings.mva;
  bus(:,3) = bus(:,3)*pi/180;

  DAE.y(Bus.v) = bus(:,2);
  DAE.y(Bus.a) = bus(:,3);
  Bus.Pg = bus(:,4);
  Bus.Qg = bus(:,5);
  Bus.Pl = bus(:,6);
  Bus.Ql = bus(:,7);

 case 'view'

  file = popupstr(findobj(Fig.uwpflow,'Tag','PopupUWFile'));
  if exist([Path.data,file]) == 2
    fm_text(13,[Path.data,file])
  else
    uiwait(fm_choice(['File "',file,'" not found.',char(10), ...
               'Check options and/or launch UWPFLOW.'],2))
  end

 case 'makecom'

  fm_disp
  fm_disp('UWPFLOW command line:')
  file = File.data;
  file = strrep(file,'(mdl)','_mdl');
  file = strrep(file,'@ ','');
  if isempty(file)
    fm_disp('No file data found. A generic file name will be used.')
    file = '<file_in>';
  end
  file_in = [file,'.cf'];
  file_out = [UWPFLOW.file,'.pf'];

  uwcom = ['uwpflow -I ',file_in,' ',file_out];

  fields = fieldnames(UWPFLOW.opt);
  Kopt = 1;
  Output = 1;
  vopt = 0;
  for i = 1:length(fields)
    opt = getfield(UWPFLOW.opt,fields{i});
    if opt.status
      uwcom = [uwcom,' ',opt.name];
      if ~isempty(opt.ext)
        uwcom = [uwcom,UWPFLOW.file,opt.ext];
      elseif ~isempty(opt.num)
        uwcom = [uwcom,num2str(opt.num)];
      end
      switch fields{i}
       case 'B'
        if ~UWPFLOW.opt.v.status
          UWPFLOW.opt.v.status = 1;
          vopt = 1;
        end
       case {'c','C','H','v'}
        if Kopt
          uwcom = [uwcom,' -K',UWPFLOW.file,'.k'];
          Kopt = 0;
        end
       case {'j','J'}
        if Output
          uwcom = [uwcom,UWPFLOW.file];
          Output = 0;
        end
      end
    end
  end

  if vopt
    UWPFLOW.opt.v.status = 0;
  end

  if ~isempty(uwcom)
    fm_disp(repmat('-',1,length(uwcom)))
    fm_disp(uwcom)
    fm_disp(repmat('-',1,length(uwcom)))
  else
    fm_disp('Something wrong in UWPFLOW options.')
    fm_disp('No command line was generated.')
  end
  if ishandle(Fig.uwpflow)
    hdl = findobj(Fig.uwpflow,'Tag','EditCom');
    set(hdl,'String',uwcom)
  end
  if nargin == 1
    UWPFLOW.command = uwcom;
  end
  if nargout
    varargout{1} = uwcom;
  end

 case 'help' % [-h] option

  if Settings.hostver < 6.01 || clpsat.init
    !uwpflow -h
    return
  end

  [status,result] = system('uwpflow -h');
  retidx = findstr(result,char(10));
  retidx = [0,retidx,length(result)+1];
  text = cell(length(retidx)-1,1);
  for i = 1:length(retidx)-1
    text{i} = result([retidx(i)+1:retidx(i+1)-1]);
  end
  if History.Max < 500,
    History.Max = 500;
    if ishandle(Fig.hist)
      set(findobj(Fig.hist,'Tag','Fmax1'),'Checked','off')
      set(findobj(Fig.hist,'Tag','Fmax2'),'Checked','off')
      set(findobj(Fig.hist,'Tag','Fmax3'),'Checked','off')
      set(findobj(Fig.hist,'Tag','Fmax4'),'Checked','on')
    end
  end
  fm_disp(text)
  if ishandle(Fig.hist), figure(Fig.hist), else, fm_hist, end
  set(Hdl.hist, ...
      'ListboxTop',length(History.text)-length(text)+1, ...
      'Value',length(History.text)-length(text)+1)

end