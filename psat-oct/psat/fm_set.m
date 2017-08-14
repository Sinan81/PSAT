function fm_set(varargin)
% FM_SET define general settings and operations for
%        the main window and other utilities
%
%FM_SET(COMMAND)
%       COMMAND = 'lf' solves power flow
%       COMMAND = 'setdata' sets data file
%       COMMAND = 'opensys' load system
%       COMMAND = 'savesys' save current system
%       etc.
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    10-Feb-2003
%Update:    27-Feb-2003
%Version:   1.0.2
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Settings
fm_var

command = varargin{1};

switch command
 case 'colormap'

  map = [0         0         0;
         0         0    0.5020;
         0         0    1.0000;
         0.5020         0         0;
         0.5020         0    0.5020;
         1.0000         0         0;
         1.0000         0    1.0000;
         0    0.5020         0;
         0    0.7530    0.5020;
         0.5020    0.5020         0;
         0.5020    0.5020    0.5020;
         0.7530    0.7530    0.7530;
         0    1.0000         0;
         0    0.7530    1.0000;
         1.0000    1.0000         0;
         1.0000    1.0000    1.0000];
  set(gcf,'ColorMap',map);

 case 'delete'

  Fig.main = -1;
  Hdl.status = -1;
  Hdl.text = -1;
  Hdl.status = -1;
  Hdl.frame = -1;
  Hdl.bar = -1;
  Hdl.axes = -1;

 case 'keypress'

  hdl = findobj(gcbf,'Tag','EditCommand');
  tasto = get(Fig.main,'CurrentCharacter');
  if isempty(tasto), return, end
  switch double(tasto)
   case 13
    fm_set('command')
   case 8
    testo = get(hdl,'String');
    if length(testo) <= 1
      testo = '';
    else
      testo = testo(1:end-1);
    end
    set(hdl,'String',testo)
   case 9
    set(hdl,'SelectionHighlight','on')
   case 127
    set(hdl,'String','')
   case 28
    stringa = get(hdl,'String');
    set(hdl,'String',stringa(1:end-1),'UserData',stringa)
   case 29
    stringa = get(hdl,'String');
    set(hdl,'String',stringa(1:end-1),'UserData',stringa)
   case 27
    fm_set('exit')
   case 30
    hdll = findobj(gcbf,'Tag','ListCommand');
    stringa = get(hdll,'String');
    value = max(get(hdll,'Value')-1,1);
        if ~strcmp(stringa{value},'<empty>'),
          set(hdl,'String',stringa{value}),
          set(hdll,'Value',max(value,1))
        end
   case 31
    hdll = findobj(gcbf,'Tag','ListCommand');
    stringa = get(hdll,'String');
    value = min(get(hdll,'Value')+1,length(stringa));
    if ~strcmp(stringa{value},'<empty>'),
      set(hdl,'String',stringa{value}),
      set(hdll,'Value',max(value,1))
    end
   otherwise
    set(hdl,'String',[get(hdl,'String'),tasto])
  end

 case 'exit'

  uiwait(fm_choice('Quit PSAT?'))
  if Settings.ok,
    a = fieldnames(Fig);
    for i = length(a):-1:1
      fig = getfield(Fig,a{i});
      if fig, close(fig), end
    end
  end

 case 'setdefault'

  uiwait(fm_choice('Set Default Values?'));
  if Settings.ok == 1
    hdl1 = findobj(gcbf,'Tag','EditText1');
    set(hdl1,'String','50');
    Settings.freq = 50;
    hdl2 = findobj(gcbf,'Tag','EditText2');
    set(hdl2,'String','100');
    Settings.mva = 100;
    hdl3 = findobj(gcbf,'Tag','EditText3');
    set(hdl3,'String','0');
    Settings.t0 = 0;
    hdl4 = findobj(gcbf,'Tag','EditText4');
    set(hdl4,'String','30');
    Settings.tf = 30;
    hdl5 = findobj(gcbf,'Tag','EditText5');
    set(hdl5,'String','1e-5');
    Settings.lftol = 1e-5;
    hdl6 = findobj(gcbf,'Tag','EditText6');
    set(hdl6,'String','20');
    Settings.lfmit = 20;
    hdl7 = findobj(gcbf,'Tag','EditText7');
    Settings.dyntol = 1e-5;
    set(hdl7,'String','1e-5');
    hdl8 = findobj(gcbf,'Tag','EditText8');
    Settings.dynmit = 20;
    set(hdl8,'String','20');

    Settings.vs = 0;
    Settings.plot = 1;
    Settings.red = 1;
    Settings.showlf = 0;
    Settings.dlf = 0;
    Settings.dac = 0;
    Settings.method = 2;
    Settings.plottype = 1;

    fm_disp('Default parameter values set.')
  else
    fm_disp('No parameter values resetting.')
  end

 case 'savesys'

  if ~Bus.n || ~Settings.init
    fm_disp('No system is loaded. ',2),
    return,
  end
  fileout = fm_filenum('out');
  filedata = strrep(File.data,'@ ','');
  filepert = strrep(File.pert,'@ ','');

  pathdata = Path.data;
  if strcmp(pathdata(1),'~')
    pathdata = [getenv('HOME'),pathdata(2:end)];
  end

  pathpert = Path.pert;
  if ~isempty(Path.pert)
    if strcmp(pathpert(1),'~')
      pathpert = [getenv('HOME'),pathpert(2:end)];
    end
  end

  filedata = strrep(filedata,'(mdl)','_mdl');
  if Settings.matlab && Settings.hostver >= 7.14,
    Source.data = ...
        strvcat(textread([pathdata,deblank(filedata),'.m'], ...
                         '%s','delimiter', ...
                         '\n','whitespace',''));

    if ~isempty(Path.pert)
      Source.pert = ...
          strvcat(textread([pathpert,deblank(filepert),'.m'], ...
                           '%s','delimiter', ...
                           '\n','whitespace',''));
    end
  else
    Source.data = ...
        char(textread([pathdata,deblank(filedata),'.m'], ...
                      '%s','delimiter', ...
                      '\n','whitespace',''));

    if ~isempty(Path.pert)
      Source.pert = ...
          char(textread([pathpert,deblank(filepert),'.m'], ...
                        '%s','delimiter', ...
                        '\n','whitespace',''));
    end
  end
  hdlpert = Hdl.pert;
  Hdl.pert = '';
  save([pathdata,fileout,'.out'])
  Hdl.pert = hdlpert;
  fm_disp
  fm_disp(['System saved in "',Path.data,fileout,'.out"'])

 case 'closepert'

  fm_disp(['Perturbation file "',Path.pert,File.pert,'" closed.'],1)
  Path.pert = '';
  File.pert = '';
  Source.pert = '';
  cd(Path.psat)
  if Settings.hostver >= 6
      Hdl.pert = str2func('pert');
  else
      Hdl.pert = 'pert';
  end
  cd(Path.local)
  hdltext = findobj(Fig.main,'Tag','EditText10');
  set(hdltext,'String','','TooltipString','');

 case 'closedata'

  fm_disp(['Data file "',Path.data,File.data,'" closed.'],1)
  Path.data = '';
  File.data = '';
  Source.data = '';
  hdltext = findobj(Fig.main,'Tag','EditText9');
  set(hdltext,'String','','TooltipString','');

 case 'savesettings'

  [fid,msg] = fopen([Path.psat,'settings.m'],'wt');
  if fid == -1
    fm_disp(msg)
    return
  end
  fields = fieldnames(Settings);
  for i = 1:length(fields)
    if strcmp(fields{i},'color')
      continue
    end
    value = eval(['Settings.',fields{i}]);
    if isnumeric(value)
      cout = fprintf(fid,'Settings.%s = %s;\n',fields{i},num2str(value));
    else
      cout = fprintf(fid,'Settings.%s = ''%s'';\n',fields{i},value);
    end
  end
  fields = fieldnames(Theme);
  for i = 1:length(fields)
    if strcmp(fields{i},'hdl')
      continue
    end
    value = eval(['Theme.',fields{i}]);
    if isnumeric(value)
      cout = fprintf(fid,'Theme.%s = [%s];\n',fields{i},num2str(value));
    else
      cout = fprintf(fid,'Theme.%s = ''%s'';\n',fields{i},value);
    end
  end
  cout = fprintf(fid,'Theme.hdl = zeros(18,1);\n');
  fclose(fid);

 case 'savedata'

  filedata = [File.data,'  '];
  if strcmp(filedata([1:2]),'@ ')
    filedata = deblank(strrep(filedata,'@ ',''));
    if isempty(Source.data),
      fm_disp('Cannot restore the data file.'),
      return,
    end
    a = dir([Path.data,'*.m']);
    b = {a.name};
    older = strmatch([filedata,'.m'],b,'exact');
    if ~isempty(older)
      uiwait(fm_choice(['Overwrite Existing File "',filedata,'.m" ?']))
      if ~Settings.ok,
        return,
      end
    end
    try
      fid = fopen([Path.data,filedata,'.m'],'wt');
      if fid == -1,
        fm_disp(['Cannot write the data file. Check folder ' ...
                 'authorizations.'],2),
        return,
      end
    catch
      fm_disp(['Cannot write the data file.  Check folder ' ...
               'authorizations.'],2)
      return
    end
    rowc = length(Source.data(1,:));
    count = fprintf(fid,[repmat('%c',1,rowc),' \n'],Source.data');
    fclose(fid);
    fm_disp(['Data file stored in "',Path.data,filedata,'.m"'])
    File.data = filedata;
    hdltext = findobj(Fig.main,'Tag','EditText9');
    set(hdltext, ...
        'String',File.data, ...
        'TooltipString',[Path.data,File.data]);

  else
    fm_disp('The current data file is already saved.')
  end

 case 'close'

  stringa = get(findobj(Fig.main,'Tag','PushClose'),'String');
  if strcmpi(stringa(end-3:end),'stop')
    set(Fig.main,'UserData',0)
  else
    close(Fig.main)
  end

 case 'opensys'

  if clpsat.init && nargin > 1
    file = varargin{2};
    pathname = varargin{3};
  else
    if ~isempty(Path.data), cd(Path.data); end
    [file,pathname] = uigetfile('d*.out',['Select System Data ' ...
                        'File']);
  end

  fm_disp
  if pathname ~= 0

    path2 = Path;
    fig2 = Fig;
    hdl2 = Hdl;
    file2 = File;
    history2 = History;
    theme2 = Theme;
    load([pathname,file],'-mat')

    dfile = strrep(file,'.out','.m');
    pfile = '';
    if ~isempty(Source.pert)
      pfile = strrep(file,'.out','.m');
      pfile(1) = 'p';
    end

    fid = fopen([pathname,dfile],'wt+');
    if fid == -1,
      fm_disp(['Cannot write the data file. Check folder ' ...
               'authorizations.'],2),
    else
      rowc = length(Source.data(1,:));
      count = fprintf(fid,[repmat('%c',1,rowc),' \n'],Source.data');
      fclose(fid);
    end
    if ~isempty(pfile)
      fid = fopen([pathname,pfile],'wt+');
      if fid == -1,
        fm_disp(['Cannot write the disturbance file. Check folder ' ...
                 'authorizations.'],2),
      else
        rowc = length(Source.pert(1,:));
        count = fprintf(fid,[repmat('%c',1,rowc),' \n'],Source.pert');
        fclose(fid);
        cd(pathname)
        if Settings.hostver >= 6
            Hdl.pert = str2func(pfile(1:end-2));
        else
            Hdl.pert = pfile(1:end-2);
        end
        cd(Path.local)
      end
    end

    hdl_data = findobj(fig2.main,'Tag','EditText9');
    hdl_pert = findobj(fig2.main,'Tag','EditText10');
    Fig = fig2;
    hdlpert = Hdl.pert;
    Hdl = hdl2;
    Hdl.pert = hdlpert;
    History = history2;
    Theme = theme2;
    if ~isempty(File.pert),
      File.pert = ['@ ',pfile(1:end-2)];
      %File.pert = strrep(File.pert,'@ @ ','@ ');
    end
    File.data = ['@ ',dfile(1:end-2)];
    %File.data = strrep(File.data,'@ @ ','@ ');

    set(hdl_data, ...
        'String',File.data, ...
        'ForegroundColor',[0 0 0.592], ...
        'TooltipString',[Path.data,File.data]);
    set(hdl_pert, ...
        'String',File.pert, ...
        'ForegroundColor',[0 0 0.592], ...
        'TooltipString',[Path.pert,File.pert]);

    Path.psat = path2.psat;
    Path.build = path2.build;
    Path.local = path2.local;
    Path.images = path2.images;
    Path.themes = path2.themes;
    Path.data = pathname;
    if ~isempty(File.pert)
      Path.pert = pathname;
    else
      Path.pert = '';
    end

    if ishandle(Fig.plot) > 0,
      close(Fig.plot),
      Fig.plot = -1;
    end
    fm_disp(['System ',pathname, file,' loaded.'])

  else
    fm_disp('No loaded system or not existent directory',2)
  end

 case 'opensim'

  [filename, pathname] = uigetfile( ...
      '*.mdl', ...
      'Pick a Simulink Model');
  if ~pathname, return, end
  cd(pathname)
  if exist(filename) ~= 4
    fm_disp('The selected file is not a Simulink model.',2)
    cd(Path.local)
    return
  end
  open_system(filename(1:end-4))
  cd(Path.local)

 case 'setdata'

  Path.temp = Path.data;
  File.temp = File.data;

  if ishandle(Fig.dir)
    set(Fig.dir,'Name','Load Data File')
    hdl = findobj(Fig.dir,'Tag','Pushbutton1');
    set(hdl,'String','Load','Callback','fm_dirset openfile')
    hdl = findobj(Fig.dir,'Tag','Listbox2');
    set(hdl,'Max',0,'ButtonDownFcn','fm_dirset openfile','Value',1)
    hdl = findobj(Fig.dir,'Tag','Pushbutton3');
    set(hdl,'Callback','fm_dirset cancel','String','Cancel')
  else
    fm_dir(1)
  end
  uiwait(Fig.dir);

  if Path.temp == 0
    fm_disp(['No data file has been selected or file does not exist'],2)
    return
  end

  if strcmp(computer,'GLNX86'),
    Path.temp = strrep(Path.temp,getenv('HOME'),'~');
  end

  if exist([Path.temp,File.temp(1:end-2)]) == 4 ...
        && strcmp(File.temp(end-1:end),'.m')
    fm_choice(['Simulink model with the same name of the ', ...
               'selected data exists. No file set.'],2)
    fm_disp('No file data set.',2)
  else
    File.data = File.temp;
    Path.data = Path.temp;
    a = dir([Path.data,File.data]);
    if isempty(a)
      fm_disp(['File "',File.data,'" does not exist.'],2)
      return
    else
      File.modify = a.date;
    end
    if ~isempty(findstr(File.data,'.mdl'))
      % make sure that the file name does not start with a number
      first = double(File.data(1));
      if first <= 57 && first >= 48
        localpath = pwd;
        cd(Path.data)
        if exist(['d',File.data]) ~= 4
          copyfile(File.data,['d',File.data])
        end
        cd(localpath)
        File.data = ['d',File.data];
      end
      exist(File.data(1:end-4));
      File.data = strrep(File.data,'.mdl','(mdl)');
    end
    File.data = strrep(File.data,'.m','');
    hdltext = findobj(Fig.main,'Tag','EditText9');
    set(hdltext,'String',File.data, ...
                'TooltipString',[Path.data,File.data]);
    if ~isempty(findstr(File.data,'(mdl)'))
      set(hdltext,'ForegroundColor',[0 0.592 0])
    else
      set(hdltext,'ForegroundColor',Theme.color07)
    end
    fm_disp(['Data file "',Path.data,File.data,'" set'],1)
    Settings.init = 0;
  end
  if ishandle(Fig.plotsel), close(Fig.plotsel), end

 case 'setpert'

  Path.temp = Path.pert;
  File.temp = File.pert;

  if ishandle(Fig.dir)
    set(Fig.dir,'Name','Load Data File')
    hdl = findobj(Fig.dir,'Tag','Pushbutton1');
    set(hdl,'String','Load','Callback','fm_dirset openfile')
    hdl = findobj(Fig.dir,'Tag','Listbox2');
    set(hdl,'Max',0,'ButtonDownFcn','fm_dirset openfile','Value',1)
    hdl = findobj(Fig.dir,'Tag','PopupMenu1');
    set(hdl,'Enbale','inactive','Value',3)
    hdl = findobj(Fig.dir,'Tag','Pushbutton3');
    set(hdl,'Callback','fm_dirset cancel','String','Cancel')
  else
    fm_dir(2)
  end

  uiwait(Fig.dir);

  if Path.temp == 0
    fm_disp('No perturbation file selected or file does not exist',2)
  else
    Path.pert = Path.temp;
    File.pert = File.temp;
    if strcmp(computer,'GLNX86'),
      Path.pert = strrep(Path.pert,getenv('HOME'),'~');
    end
    cd(Path.pert)
    lfile = length(File.pert);
    File.pert = File.pert(1:lfile-2);
    if Settings.hostver >= 6
      Hdl.pert = str2func(File.pert);
    else
      Hdl.pert = File.pert;
    end
    cd(Path.local)
    hdltext = findobj(Fig.main,'Tag','EditText10');
    set(hdltext,'String',File.pert, ...
                'ForegroundColor',Theme.color07, ...
                'TooltipString',[Path.pert,File.pert]);
    fm_disp(['Perturbation file "',Path.pert,File.pert,'" set'],1)
  end

 case 'command'

  hdl = findobj(gcbf,'Tag','EditCommand');
  stringa = get(hdl,'String');
  set(hdl,'String','');
  hdl = findobj(gcbf,'Tag','ListCommand');
  comandi = get(hdl,'String');
  if strcmp(comandi{1},'<empty>'),
    comandi{1,1} = stringa;
  else,
    comandi{end+1,1} = stringa;
  end
  if length(comandi) > 100, comandi(1) = []; end
  set(hdl,'String',comandi,'Value',length(comandi));
  if strcmp(stringa,'command'),
    fm_disp('Invalid command',2),
    return,
  end
  if strcmp(stringa,'<empty>'), return, end
  try
    try,
      eval(['fm_set ',stringa])
    catch,
      eval(stringa);
      fm_disp(['Command "',stringa,'" executed.'])
    end
  catch
    fm_disp(lasterr,2)
  end

 case 'listcommand'

  if strcmp(get(Fig.main,'SelectionType'),'open')
    hdl = findobj(gcbf,'Tag','ListCommand');
    stringa = get(hdl,'String');
    value = get(hdl,'Value');
    hdl = findobj(gcbf,'Tag','EditCommand');
    set(hdl,'String',stringa{value});
    fm_set('command')
  end

 case 'lf'

  if isempty(File.data),
    fm_disp('Set a data file before running Power Flow.',2),
    return,
  end

  if Settings.freq <= 0
    Settings.freq = 50;
    if ishandle(Fig.main)
      hdl = findobj(Fig.main,'Tag','EditText1');
      set(hdl,'String',num2str(Settings.freq))
    end
  end
  if Settings.mva <= 0
    Settings.mva = 100;
    if ishandle(Fig.main)
      hdl = findobj(Fig.main,'Tag','EditText2');
      set(hdl,'String',num2str(Settings.mva))
    end
  end

  filedata = strrep([File.data,'  '],'@ ','');

  if ~isempty(findstr(filedata,'(mdl)'))
    filedata1 = File.data(1:end-5);
    open_sys = find_system('type','block_diagram');
    OpenModel = sum(strcmp(open_sys,filedata1));
    if OpenModel
      if strcmp(get_param(filedata1,'Dirty'),'on') || ...
            str2num(get_param(filedata1,'ModelVersion')) > Settings.mv,
        check = sim2psat;
        if ~check, return, end
      end
    end
  end
  try
    cd(Path.data)
  catch
    fm_disp('Data folder does not exist (maybe it was removed).',2)
    return
  end
  filedata = deblank(strrep(filedata,'(mdl)','_mdl'));
  a = exist(filedata);
  if ~a
    fm_disp('Data file does not exist (maybe it was removed).',2)
    cd(Path.local)
    return
  end

  if a == 2,
    lasterr('');
    b = dir([filedata,'.m']);
    %if ~strcmp(File.modify,b.date) || clpsat.readfile
    if clpsat.readfile
      try
        fm_inilf
        clear(filedata)
        eval(filedata);
        File.modify = b.date;
      catch
        fm_disp(lasterr),
        fm_disp(['Something wrong with the data file "',filedata,'"']),
        cd(Path.local)
        return
      end
    end
  else
    fm_disp(['File "',filedata,'" not found or not an m-file'],2)
  end
  cd(Path.local)

  if Settings.static % do not use dynamic components
    for i = 1:Comp.n
      comp_con = [Comp.names{i},'.con'];
      comp_ext = eval(['~isempty(',comp_con,')']);
      if comp_ext && ~Comp.prop(i,6)
        eval([comp_con,' = [];']);
      end
    end
  end

  % the following code is needed for compatibility with older PSAT versions

  if isfield(Varname,'bus')
    if ~isempty(Varname.bus)
      Bus.names = Varname.bus;
      Varname = rmfield(Varname,'bus');
    end
  end

  if exist('Mot')
    if isfield(Mot,'con')
      Ind.con = Mot.con;
      clear Mot
    end
  end

  % end of compatibility code %

  if ishandle(Fig.main)
    hdl = findobj(Fig.main,'Tag','EditText3');
    time0 = str2num(get(hdl,'String'));
    if time0 ~= Settings.t0,
      set(hdl,'String',num2str(Settings.t0)),
      fm_disp(['Initial simulation time "t0" set to ',num2str(Settings.t0),' s'])
    end
    hdl = findobj(Fig.main,'Tag','EditText4');
    timef = str2num(get(hdl,'String'));
    if timef ~= Settings.tf,
      set(hdl,'String',num2str(Settings.tf)),
      fm_disp(['Final simulation time "tf" set to ',num2str(Settings.tf),' s'])
    end
    set(Fig.main,'Pointer','watch');
  end

  Settings.init = 0;
  fm_spf
  if ishandle(Fig.main), set(Fig.main,'Pointer','arrow'); end
  SNB.init = 0;
  LIB.init = 0;
  CPF.init = 0;
  OPF.init = 0;

  % ---------------------------------------------------------------------------
  %case 'stabrep'
  %for i = 1:Bus.n;  [Istab(i),Vnew(i),angnew(i)]= fm_stab(i,0);
  %end
  %fid = fopen([Path.data,'vstab.txt'], 'wt');
  %count = fprintf(fid, 'Voltage Stability Index at Network
  %Buses\n\n');
  %count = fprintf(fid, '#bus         Index       V    phase\n\n');
  %for i = 1:Bus.n
  %    count = fprintf(fid,[fvar(Bus.names{i},12),
  %    fvar(Istab(i),12), ...
  %                         fvar(Vnew(i),12),
  %                         fvar(angnew(i),12),'\n']);
  %end
  %count = fclose(fid);
  %fm_text(13,[Path.data,'vstab.txt'])
  % ---------------------------------------------------------------------------

 case 'opf'

  if max(OPF.lmin) > OPF.lmax
    fm_disp('Lambda_min must be less than Lambda_max.',2)
    return
  end
  [ao,bo] = size(OPF.omega);
  [al,bl] = size(OPF.lmin);
  ao = ao*bo;
  a1 = al*bl;

  switch OPF.type
   case 1
    OPF.show = 1;
    if ao > 1,
      fm_disp(['Single OPF selected. Only the 1th value of ' ...
               'the weighting factor will be used.'])
    end
    if a1 > 1,
      fm_disp(['Single OPF selected. Only the 1th value ' ...
               'of the min load parameter will be used.'])
    end
    OPF.w = OPF.omega(1);
    OPF.lmin = OPF.lmin(1);
    if ishandle(Fig.opf)
      hdl_omeg = findobj(Fig.opf,'Tag','EditText1');
      hdl_lmin = findobj(Fig.opf,'Tag','EditText2');
      set(hdl_omeg,'String',num2str(OPF.omega_s))
      set(hdl_lmin,'String',num2str(OPF.lmin))
    end
    if OPF.w == 0,
      fm_opfm
    else,
      fm_opfsdr
    end
   case 2
    if ao == 1,
      OPF.show = 1;
      OPF.w = OPF.omega;
      fm_disp(['The weighting factor is scalar. Single OPF will be ' ...
               'run.'])
      if OPF.w == 0,
        fm_opfm
      else,
        fm_opfsdr
      end
    else
      OPF.fun = 'fm_opfsdr';
      fm_pareto
    end
   case 3,
    uiwait(fm_choice('Sorry! Daily forecast not implemented yet ...',2))
   case 4,
    fm_atc
   case 5,
    fm_atc
  end

 case 'appendV'

  type = varargin{2};

  if isempty(File.data),
    fm_disp('No data file loaded.',2),
    return,
  end
  filedata = strrep(File.data,'@ ','');
  if Settings.init == 0,
    fm_disp('Run power flow before saving voltages.',2),
    return,
  end

  if isempty(strfind(filedata,'(mdl)'))
    fid = fopen([Path.data,filedata,'.m'],'r+');
    count = fseek(fid,0,1);
    switch type
     case 'flat'
      count = fprintf(fid, '\n\nBus.con(:,3) = 1;\n ');
      count = fprintf(fid, 'Bus.con(:,4) = 0;\n ');
      count = fprintf(fid, 'SW.con(:,10) = 0;\n ');
     otherwise
      count = fprintf(fid, '\n\n\nBus.con(:,3) = [...\n      ');
      for i = 1:Bus.n-1
        count = fprintf(fid,'%10.7f;',DAE.y(Bus.v(i)));
        if rem(i,5) == 0;
          count = fprintf(fid,'\n      ');
        end
      end
      count = fprintf(fid,'%10.7f];\n\n',DAE.y(Bus.v(Bus.n)));
      count = fprintf(fid, 'Bus.con(:,4) = [...\n      ');
      for i = 1:Bus.n-1
        count = fprintf(fid, '%10.7f;',DAE.y(Bus.a(i)));
        if rem(i,5) == 0;
          count = fprintf(fid,'\n      ');
        end
      end
      count = fprintf(fid,'%10.7f];\n\n',DAE.y(Bus.a(Bus.n)));
      for i = 1:SW.n
        Pg = Settings.mva*Bus.Pg(SW.bus(i))/SW.con(i,2);
        count = fprintf(fid,'SW.con(%d,10) = %10.7f;\n',i,Pg);
      end
    end
    fclose(fid);
    fm_disp(['Voltages appended in file "',Path.data,File.data,'"'])
  else
    % load Simulink Library and update Bus blocks
    load_system('fm_lib');
    cd(Path.data);
    filedata = filedata(1:end-5);
    open_sys = find_system('type','block_diagram');
    if ~sum(strcmp(open_sys,filedata))
      open_system(filedata);
    end
    cur_sys = get_param(filedata,'Handle');
    blocks = find_system(gcs,'MaskType','Bus');
    if length(blocks) ~= Bus.n
      fm_disp('The number of "Bus" blocks does not match current bus number',2)
      return
    end
    switch type
     case 'flat'
      for i = 1:length(blocks)
        set_param(blocks{i},'p3_4q','[1  0]')
      end
     otherwise
      for i = 1:length(blocks)
        set_param( ...
            blocks{i}, 'p3_4q', ...
            ['[',num2str([DAE.y(Bus.v(i)),DAE.y(Bus.a(i))]),']'])
      end
    end
    cd(Path.local);
  end

 otherwise

  error('The string is not a valid command')

end