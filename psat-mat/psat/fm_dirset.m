function varargout = fm_dirset(type)
% FM_DIRSET define settings and actions for the data format
%           conversion GUI
%
% FM_DIRSET(TYPE)
%      TYPE action indentifier
%
%see also FM_DIR
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    05-Jul-2003
%Update:    31-Jul-2003
%Update:    07-Oct-2003
%Version:   1.1.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Path Fig Settings Theme

if ishandle(Fig.dir)
  hdl = findobj(Fig.dir,'Tag','PopupMenu1');
  formato = get(hdl,'Value');
  hdl_dir = findobj(Fig.dir,'Tag','EditText1');
  folder1 = get(hdl_dir,'String');
  if ischar(folder1) && isdir(folder1), cd(folder1), end
end

% codes:
IEEE = 1;
PSAT = 2;
PSATPERT = 3;
PSATMDL = 4;
CYME = 5;
MATPOWER = 6;
PST = 7;
EPRI = 8;
PSSE = 9;
PSAP = 10;
EUROSTAG = 11;
TH = 12;
CESI = 13;
VST = 14;
SIMPOW = 15;
NEPLAN = 16;
DIGSILENT = 17;
POWERWORLD = 18;
PET = 19;
FLOWDEMO = 20;
GEEPC = 21;
CHAPMAN = 22;
UCTE = 23;
PCFLO = 24;
WEBFLOW = 25;
IPSS = 26;
CEPEL = 27;
ODM = 28;
REDS = 29;
VITRUVIO = 30; % all files

switch type

 case 'formatlist'

  formati = cell(VITRUVIO,1);
  formati{IEEE} = 'IEEE CDF (.dat, .txt, .cf)';
  formati{CYME} = 'CYME (.nnd, .sf)';
  formati{MATPOWER} = 'MatPower (.m)';
  formati{PSAT} = 'PSAT data (.m)';
  formati{PSATPERT} = 'PSAT pert. (.m)';
  formati{PSATMDL} = 'PSAT Simulink (.mdl)';
  formati{PST} = 'PST (.m)';
  formati{EPRI} = 'EPRI (.wsc, .txt, .dat)';
  formati{PSSE} = 'PSS/E (.raw)';
  formati{PSAP} = 'PSAP (.dat)';
  formati{EUROSTAG} = 'Eurostag (.dat)';
  formati{TH} = 'TH (.dat)';
  formati{CESI} = 'CESI - INPTC1 (.dat)';
  formati{VST} = 'VST (.dat)';
  formati{SIMPOW} = 'SIMPOW (.optpow)';
  formati{NEPLAN} = 'NEPLAN (.ndt)';
  formati{DIGSILENT} = 'DigSilent (.dgs)';
  formati{POWERWORLD} = 'PowerWorld (.aux)';
  formati{PET} = 'PET (.pet)';
  formati{FLOWDEMO} = 'Flowdemo.net (.fdn)';
  formati{GEEPC} = 'GE format (.epc)';
  formati{CHAPMAN} = 'Chapman format';
  formati{UCTE} = 'UCTE format';
  formati{PCFLO} = 'PCFLO format';
  formati{WEBFLOW} = 'WebFlow format';
  formati{IPSS} = 'InterPSS format (.ipss)';
  formati{CEPEL} = 'CEPEL format (.txt)';
  formati{ODM} = 'ODM format (.odm, .xml)';
  formati{REDS} = 'REDS format (.pos)';
  formati{VITRUVIO} = 'All Files (*.*)';
  varargout(1) = {formati};

 %==================================================================
 case 'changedir'

  hdl = findobj(Fig.dir,'Tag','Listbox1');
  cdir = get(hdl,'String');
  ndir = get(hdl,'Value');
  namedir = cdir{ndir(1),1};
  switch namedir
   case '..'
    eval('cd ..');
   case '.'
    if ~isempty(dir(namedir))
      cd(namedir);
    end
   case '[ * DATA * ]'
    if isempty(Path.data), return, end
    cd(Path.data)
   case '[ * PERT * ]'
    if isempty(Path.pert), return, end
    cd(Path.pert)
   case '[ * LOCAL * ]'
    if isempty(Path.local), return, end
    cd(Path.local)
   case '[ * PSAT * ]'
    if isempty(Path.psat), return, end
    cd(Path.psat)
   otherwise
    cd(namedir)
  end
  a = dir;
  numdir = find([a.isdir] == 1);
  cdir = {a(numdir).name}';
  cdir(strmatch('.',cdir)) = [];
  cdir(strmatch('@',cdir)) = [];
  set(hdl,'ListboxTop',1,'String',[{'.'; '..'};cdir;get(hdl,'UserData')],'Value',1);
  hdl = findobj(Fig.dir,'Tag','EditText1');
  set(hdl,'String',pwd);
  set(Fig.dir,'UserData',pwd);
  hdl = findobj(Fig.dir,'Tag','Listbox2');
  hdlf = findobj(Fig.dir,'Tag','PopupMenu1');
  cfile = uform(get(hdlf,'Value'));
  if isempty(cfile)
    cfile = 'empty';
  else
    cfile = sort(cfile);
  end
  set(hdl,'ListboxTop',1,'String',cfile,'Value',1);

 %==================================================================
 case 'chformat'

  if ~ishandle(Fig.dir), return; end
  if ~strcmp(get(Fig.dir, 'Type'), 'figure'), return; end

  hdlf = findobj(Fig.dir,'Tag','PopupMenu1');
  formato = get(hdlf,'Value');
  if ~length(formato)
    formato = 1
  end
  % display(formato)
  hdl = findobj(Fig.dir,'Tag','Listbox2');
  hdla = findobj(Fig.dir,'Tag','Axes1');
  hdlc = findobj(Fig.dir,'Tag','Pushbutton1');
  hdl1 = findobj(Fig.dir,'Tag','CheckboxSilent');
  hdl2 = findobj(Fig.dir,'Tag','Checkbox2');
  hdl4 = findobj(Fig.dir,'Tag','StaticText2');
  hdlp = findobj(Fig.dir,'Tag','PushbuttonPreview');
  cfile = uform(formato);

  switch int32(formato)
   case IEEE, file = 'ieee';
   case CYME, file = 'cyme';
   case MATPOWER, file = 'pserc';
   case PSAT, file = 'psatdata';
   case PSATPERT, file = 'psatpert';
   case PSATMDL, file = 'simulink';
   case PST, file = 'cherry';
   case EPRI, file = 'epri';
   case PSSE, file = 'pti';
   case PSAP, file = 'pjm';
   case EUROSTAG, file = 'eurostag';
   case TH, file = 'th';
   case CESI, file = 'cesi';
   case VST, file = 'cepe';
   case SIMPOW, file = 'simpow';
   case NEPLAN, file = 'neplan';
   case DIGSILENT, file = 'digsilent';
   case POWERWORLD, file = 'powerworld';
   case PET, file = 'pet';
   case FLOWDEMO, file = 'eeh';
   case GEEPC, file = 'ge';
   case CHAPMAN, file = 'chapman';
   case UCTE, file = 'ucte';
   case PCFLO, file = 'pcflo';
   case WEBFLOW, file = 'webflow';
   case IPSS, file = 'ipss';
   case CEPEL, file = 'cepel';
   case ODM, file = 'odm';
   case REDS, file = 'reds';
   case VITRUVIO, file = 'vitruvio';
  end

  switch formato
   case VITRUVIO,
    if ~get(hdlf,'UserData'), set(hdlc,'Enable','off'), end
    set(hdl1,'Enable','off')
    set(hdl2,'Enable','off')
    set(hdl4,'Enable','off')
   case PSAT,
    set(hdlc,'Enable','on')
    set(hdl1,'Enable','off')
    if ~get(hdlf,'UserData'), set(hdl2,'Enable','on'), end
    if ~get(hdlf,'UserData'), set(hdl4,'Enable','on'), end
  case PSATPERT,
    if ~get(hdlf,'UserData'), set(hdlc,'Enable','off'), end
    set(hdl1,'Enable','off')
    set(hdl2,'Enable','off')
    set(hdl4,'Enable','off')
   case {NEPLAN,CESI}
    set(hdlc,'Enable','on')
    set(hdl1,'Enable','on')
    set(hdl2,'Enable','off')
    set(hdl4,'Enable','off')
   otherwise % all other formats
    set(hdlc,'Enable','on')
    set(hdl1,'Enable','off')
    set(hdl2,'Enable','off')
    set(hdl4,'Enable','off')
  end

  if formato == PSATMDL
    set(hdlp,'Enable','on')
    set(hdlp,'Visible','on')
  else
    set(hdlp,'Enable','off')
    set(hdlp,'Visible','off')
  end

  a = imread([Path.images,'logo_',file,'.jpg'],'jpg');

  [yl,xl,zl] = size(a);
  set(Fig.dir,'Units','pixels')
  figdim = get(Fig.dir,'Position');
  % the following if-block is needed for some issues on Matlab R2008a
  if figdim(3) < 1
    if strcmp(get(0,'Units'),'pixels')
      ssize = get(0,'ScreenSize');
      figdim(3) = ssize(3)*figdim(3);
      figdim(4) = ssize(4)*figdim(4);
    else
      set(0,'Units','pixels')
      ssize = get(0,'ScreenSize');
      figdim(3) = ssize(3)*figdim(3);
      figdim(4) = ssize(4)*figdim(4);
    end
  end
  set(Fig.dir,'Units','normalized')
  dimx = figdim(3)*0.2616;
  dimy = figdim(4)*0.3468;
  rl = xl/yl;
  if dimx > xl && dimy > yl
    xd = xl/figdim(3);
    yd = yl/figdim(4);
    set(hdla,'Position',[0.8358-xd/2, 0.5722-yd/2, xd, yd]);
  elseif xl > yl
    xd = 0.2616;
    yd = 0.3468/rl;
    set(hdla,'Position',[0.7050, 0.5722-0.1734/rl, xd, yd]);
  else
    xd = 0.2616*rl;
    yd = 0.3468;
    set(hdla,'Position',[0.8358-0.1308*rl, 0.3988, xd, yd]);
  end
  xd = round(xd*figdim(3));
  yd = round(yd*figdim(4));
  %disp([xl yl xd yd])
  if xd ~= xl && yd ~= yl
    try
      if Settings.hostver >= 7.04
        a = imresize(a,[yd xd],'bilinear');
      else
        a = imresize(a,[yd xd],'bilinear',11);
      end
    catch
      % imresize is not available!!!
    end
  end
  set(hdla,'XLim',[0.5 xd+0.5],'YLim',[0.5  yd+0.5]);

  if Settings.hostver < 8.04
    if length(get(hdla,'Children')) > 1
      h2 = image( ...
          'Parent',hdla, ...
          'CData',a, ...
          'Erase','none', ...
          'Tag','Axes1Image1', ...
          'XData',[1 xd], ...
          'YData',[1 yd]);
    else
      set(get(hdla,'Children'),'CData',a,'XData',[1 xd],'YData',[1 yd]);
    end
  else
    if length(get(hdla,'Children')) > 1
      set(hdla, 'XDir', 'reverse');
      h2 = image( ...
          'Parent',hdla, ...
          'CData',flipud(a), ...
          'Erase','none', ...
          'Tag','Axes1Image1', ...
          'XData',[1 xd], ...
          'YData',[1 yd]);
    else
      set(hdla, 'XDir', 'reverse');
      set(get(hdla,'Children'), ...
          'CData',flipud(a), ...
          'XData',[1 xd], ...
          'YData',[1 yd])
    end
  end
  set(hdla,'XTick',[],'XTickLabel','','XColor',Theme.color01);
  set(hdla,'YTick',[],'YTickLabel','','YColor',Theme.color01);
  if ispc, set(hdla,'XColor',[126 157 185]/255,'YColor',[126 157 185]/255), end
  if isempty(cfile), cfile = 'empty'; else, cfile = sort(cfile); end
  set(hdl,'ListboxTop',1,'String',cfile,'Value',1);
  Settings.format = formato;

 %==================================================================
 case 'editinit'

  if ~isempty(Path.temp)
    try
      cd(Path.temp);
    catch
      % nothing to do
    end
  elseif ~isempty(Path.data)
    try
      cd(Path.data);
    catch
      % nothing to do
    end
  end
  set(gcbo,'String',pwd)
  set(gcf,'UserData',pwd);

 %==================================================================
 case 'dirinit'

  devices = getdevices;
  devices{end+1,1} = '[ * DATA * ]';
  devices{end+1,1} = '[ * PERT * ]';
  devices{end+1,1} = '[ * LOCAL * ]';
  devices{end+1,1} = '[ * PSAT * ]';
  set(gcbo,'UserData',devices)

  cd(get(gcf,'UserData'))
  a = dir;
  numdir = find([a.isdir] == 1);
  if isempty(numdir)
    cdir = {' '};
  else
    cdir = {a(numdir).name}';
    cdir(strmatch('.',cdir)) = [];
    cdir(strmatch('@',cdir)) = [];
  end
  set(findobj(Fig.dir,'Tag','Listbox1'),'ListboxTop',1, ...
      'String',[{'.';'..'}; cdir; devices],'Value',1);

 %==================================================================
 case 'dirsel'

  %values = get(gcbo,'Value');
  %set(gcbo,'Value',values(end));
  if strcmp(get(Fig.dir,'SelectionType'),'open')
    cd(Path.local)
    fm_dirset('changedir');
  end

 %==================================================================
 case 'diredit'

  hdl = findobj(Fig.dir,'Tag','EditText1');
  cartella = get(hdl,'String');
  try
    cd(cartella);
    hdl = findobj(Fig.dir,'Tag','Listbox1');
    a = dir;
    cdir = {'.';'..'};
    numdir = find([a.isdir] == 1);
    j = 2;
    for i = 1:length(numdir)
      if ~strcmp(a(numdir(i)).name(1),'.') && isunix
        j = j + 1;
        cdir{j,1} = a(numdir(i)).name;
      end
    end
    if isempty(cdir),
      cdir = ' ';
    else,
      cdir = sort(cdir);
    end
    set(hdl,'ListboxTop',1,'String',[cdir;get(hdl,'UserData')],'Value',1);
    hdl = findobj(Fig.dir,'Tag','Listbox2');
    cfile = uform(formato);
    if isempty(cfile),
      cfile = 'empty';
    else,
      cfile = sort(cfile);
    end
    set(hdl,'ListboxTop',1,'String',cfile,'Value',1);
    set(Fig.dir,'UserData',cartella);
  catch
    fm_disp(lasterr,2)
    set(hdl_dir,'String',get(Fig.dir,'UserData'));
  end

 %==================================================================
 case 'getfolder'

  pathname = get(Fig.dir,'UserData');
  cartella = uigetdir(pathname);
  if cartella
    hdl = findobj(Fig.dir,'Tag','EditText1');
    set(hdl,'String',cartella);
    cd(Path.local)
    fm_dirset('diredit');
  end

 %==================================================================
 case 'convert'

  hdl = findobj(Fig.dir,'Tag','Listbox2');
  numfile = get(hdl,'Value');
  nomefile = get(hdl,'String');
  if ~iscell(nomefile),
    nomefile = cellstr(nomefile);
  end
  hdl = findobj(Fig.dir,'Tag','PopupMenu1');

  if numfile == 1 && strcmp(nomefile{1},'empty')
    fm_disp('Current folder does not contain files in the selected format.',2)
    cd(Path.local)
    return
  end

  % if coverting a PSAT file, get destination format
  hdlpsat = findobj(Fig.dir,'Tag','Checkbox2');
  convpsat = get(hdlpsat,'Value');

  for i = 1:length(numfile)
    lasterr('');
    filename = nomefile{numfile(i),1};
    check = 0;
    switch get(hdl,'Value')
     case IEEE
      check = fm_perl('IEEE CDF','ieee2psat',filename);
     case CYME
      check = fm_perl('CYME','cyme2psat',filename);
     case MATPOWER
      check = matpower2psat(filename,pwd);
     case PSAT
      switch convpsat
       case 1, check = psat2ieee(filename,pwd);
       case 2, check = psat2epri(filename,pwd);
       case 3, check = psat2odm(filename,pwd);
      end
     case PSATMDL
      first = double(filename(1));
      if first <= 57 && first >= 48
        copyfile(filename,['d',filename])
        filename = ['d',filename];
        fm_disp(['Use modified file name <',filename,'>'])
      end
      check = sim2psat(filename,pwd);
     case PSATPERT
      fm_disp('No filter is associated with pertubation files.')
     case PST
      check = pst2psat(filename,pwd);
     case EPRI
      check = fm_perl('WSCC','epri2psat',filename);
     case PSSE
      check = fm_perl('PSS/E','psse2psat',filename);
     case PSAP
      check = fm_perl('PSAP','psap2psat',filename);
     case EUROSTAG
      check = fm_perl('EUROSTAG','eurostag2psat',filename);
     case TH,
      check = fm_perl('TH','th2psat',filename);
     case CESI,
      check = fm_perl('CESI','inptc12psat',filename);
     case VST
      check = fm_perl('VST','vst2psat',filename);
     case SIMPOW
      check = fm_perl('SIMPOW','simpow2psat',filename);
     case NEPLAN
      check = fm_perl('NEPLAN','neplan2psat',filename);
     case DIGSILENT
      check = fm_perl('DIGSILENT','digsilent2psat',filename);
     case POWERWORLD
      check = fm_perl('PowerWorld','pwrworld2psat',filename);
     case PET
      fm_choice('Filter for PET data format has not been implemeted yet',2)
      break
     case FLOWDEMO
      check = fm_perl('FlowDemo.net','flowdemo2psat',filename);
     case GEEPC
      check = fm_perl('GE','ge2psat',filename);
     case CHAPMAN
      check = fm_perl('Chapman','chapman2psat',filename);
     case UCTE
      check = fm_perl('UCTE','ucte2psat',filename);
     case PCFLO
      check = fm_perl('PCFLO','pcflo2psat',filename);
     case WEBFLOW
      check = fm_perl('WebFlow','webflow2psat',filename);
     case CEPEL
      check = fm_perl('CEPEL','cepel2psat',filename);
     case ODM
      check = fm_perl('ODM','odm2psat',filename);
     case REDS
      check = fm_perl('REDS','reds2psat',filename);
     case IPSS
      if ~isempty(strfind(filename,'.ipssdat'))
        check = fm_perl('InterPSS','ipssdat2psat',filename);
      else
        check = fm_perl('InterPSS','ipss2psat',filename);
      end
     case VITRUVIO  % All files
      fm_disp('Select a Data Format for running the conversion.')
    end
    if ~check && ~isempty(lasterr), fm_disp(lasterr), end
  end
  if nargout, varargout{1} = check; end

 %==================================================================
 case 'openfile'

  global File
  Path.temp = 0;
  File.temp = '';

  hdl = findobj(Fig.dir,'Tag','Listbox2');
  numfile = get(hdl,'Value');
  nomefile = get(hdl,'String');
  if ~iscell(nomefile),
    nomefile = cellstr(nomefile);
  end

  if numfile == 1 && strcmp(nomefile{1},'empty')
    fm_disp('Current folder does not contain files in the selected data format.',2)
    cd(Path.local)
    close(Fig.dir)
    return
  end

  hdl = findobj(Fig.dir,'Tag','PopupMenu1');
  type = get(hdl,'Value');

  if type == PSAT || type == PSATPERT || type == VITRUVIO
    check = 1;
  else
    cd(Path.local)
    check = fm_dirset('convert');
  end
  if ~check
    fm_disp('Data conversion failed.',2)
    return
  end

  % determine file name
  namefile = nomefile{numfile};
  switch type
   case {PSAT,PSATPERT,PSATMDL,VITRUVIO}
    % nothing to do!
   case PCFLO
    namefile = regexprep([namefile,'.m'],'^bdat\.','','ignorecase');
    namefile = regexprep(['d_',namefile],'^d*_*','d_');
    namefile = regexprep(namefile,'[^\w\.]','_');
   case PST
    namefile = strrep(namefile,'.m','_pst.m');
    if ~strcmp(namefile(1), 'd'); namefile = ['d_',namefile]; end
   case MATPOWER
    extension = findstr(namefile,'.');
    namefile = ['d_',namefile(1:extension(end)-1),'.m'];
   otherwise
    namefile = regexprep(['d_',namefile],'^d*_*','d_');
    namefile = regexprep(namefile,'^d_d','d_');
    namefile = regexprep(namefile,'^d__','d_');
    namefile = regexprep(namefile,'[^\w\.]','_');
    namefile = regexprep(namefile,'\..+$','.m');
  end

  Path.temp = get(Fig.dir,'UserData');
  if ~strcmp(Path.temp(end),filesep)
    Path.temp = [Path.temp,filesep];
  end
  File.temp = namefile;
  close(Fig.dir)

 %==================================================================
 case 'cancel'

  Path.temp = 0;
  File.temp = '';
  close(Fig.dir)

 %==================================================================
 case 'preview'

  global File

  % check whether the selected file is a Simulink model
  hdl = findobj(Fig.dir,'Tag','PopupMenu1');
  type = get(hdl,'Value');
  if type ~= PSATMDL
    cd(Path.local)
    return
  end

  % get the name of the Simulink model
  hdl = findobj(Fig.dir,'Tag','Listbox2');
  numfile = get(hdl,'Value');
  if length(numfile) > 1
    numfile = numfile(1);
    temp = get(hdl,'String');
    namefile = temp{numfile};
  else
    files = get(hdl,'String');
    if iscell(files)
      namefile = files{numfile};
    else
      namefile = files;
    end
  end

  % make sure that the file name does not start with a number
  first = double(namefile(1));
  if first <= 57 && first >= 48
    copyfile(namefile,['d',namefile])
    namefile = ['d',namefile];
  end

  oldpath = Path.data;
  oldfile = File.data;

  Path.data = pwd;
  File.data = [namefile(1:end-4),'(mdl)'];

  hdla = findobj(Fig.dir,'Tag','Axes1');

  lasterr('')
  try
    fm_simrep('DrawModel',0,0,0)
  catch
    disp(' ')
    fm_disp('* * * The model likely refers to an old PSAT/Simulink library.')
    fm_disp('      Load and update the model before trying to preview it.')
    fm_dirset chformat
    return
  end

  %set(hdla,'XLimMode','auto')
  %set(hdla,'YLimMode','auto')

  x_lim = get(hdla,'XLim');
  y_lim = get(hdla,'YLim');
  xl = x_lim(2)-x_lim(1);
  yl = y_lim(2)-y_lim(1);

  set(Fig.dir,'Units','pixels')
  figdim = get(Fig.dir,'Position');
  set(Fig.dir,'Units','normalized')

  dimx = figdim(3)*0.2616;
  dimy = figdim(4)*0.3468;

  rl = xl/yl;
  if dimx > xl && dimy > yl
    xd = xl/figdim(3);
    yd = yl/figdim(4);
    set(hdla,'Position',[0.8358-xd/2, 0.5722-yd/2, xd, yd]);
  elseif xl > yl
    xd = 0.2616;
    yd = 0.3468/rl;
    set(hdla,'Position',[0.7050, 0.5722-0.1734/rl, xd, yd]);
  else
    xd = 0.2616*rl;
    yd = 0.3468;
    set(hdla,'Position',[0.8358-0.1308*rl, 0.3988, xd, yd]);
  end

  Path.data = oldpath;
  File.data = oldfile;


 %==================================================================
 case 'view'

  hdl = findobj(Fig.dir,'Tag','Listbox2');
  numfile = get(hdl,'Value');
  nomefile = get(hdl,'String');
  if ~iscell(nomefile), nomefile = cellstr(nomefile); end
  if strcmp(nomefile{1},'empty')
    fm_disp('Folder is empty or does not contain files in the selected data format',2)
    cd(Path.local)
    return
  end
  for i = 1:length(numfile)
    ext = lower(nomefile{numfile(i),1}(end-2:end));
    idx = findstr(ext,'.');
    if ~isempty(idx)
      ext = ext(idx(end)+1:end);
    end
    file = nomefile{numfile(i),1};
    try
      switch ext
       case 'mdl'
        open_system(file)
       case 'pdf',
        switch computer
         case 'GLNX86', eval(['! xpdf ',file, ' &']),
         case 'PCWIN', eval(['! acroread ',file, ' &'])
         otherwise 'SOL2', eval(['! acroread ',file, ' &'])
        end
       case '.ps'
        switch computer
         case 'GLNX86', eval(['! gsview ',file, ' &']),
         case 'PCWIN', eval(['! gsview ',file, ' &'])
         otherwise, eval(['! ghostview ',file, ' &'])
        end
       case 'eps'
        switch computer
         case 'GLNX86', eval(['! gsview ',file, ' &']),
         case 'PCWIN', eval(['! gsview ',file, ' &'])
         otherwise, eval(['! ghostview ',file, ' &'])
        end
       case 'doc'
        switch computer
         case 'GLNX86', eval(['! AbiWord ',file, ' &']),
         case 'PCWIN', eval(['! WINWORD ',file, ' &'])
         otherwise, fm_disp('Unknown viewer on this platform for file "',file,'"')
        end
       case 'ppt'
        switch computer
         case 'GLNX86', eval(['! AbiWord ',file, ' &']),
         case 'PCWIN', eval(['! POWERPNT ',file, ' &'])
         otherwise, fm_disp('Unknown viewer on this platform for file "',file,'"')
        end
       case 'dvi'
        switch computer
         case 'GLNX86', eval(['! xdvi ',file, ' &']),
         case 'PCWIN', fm_disp('Unknown viewer on this platform for file "',file,'"')
         otherwise, eval(['! xdvi ',file, ' &'])
        end
       case 'jpg', fm_iview(file)
       case 'tif', fm_iview(file)
       case 'gif', fm_iview(file)
       case 'bmp', fm_iview(file)
       case 'png', fm_iview(file)
       case 'hdf', fm_iview(file)
       case 'pcx', fm_iview(file)
       case 'xwd', fm_iview(file)
       case 'ico', fm_iview(file)
       case 'cur', fm_iview(file)
       otherwise,  fm_text(13,file)
      end
    catch
      fm_disp(['Error in opeining file "',file,'":  ',lasterr])
    end
  end

end

cd(Path.local)

%===================================================================
function cfile = uform(formato)

% codes
IEEE = 1;
PSAT = 2;
PSATPERT = 3;
PSATMDL = 4;
CYME = 5;
MATPOWER = 6;
PST = 7;
EPRI = 8;
PSSE = 9;
PSAP = 10;
EUROSTAG = 11;
TH = 12;
CESI = 13;
VST = 14;
SIMPOW = 15;
NEPLAN = 16;
DIGSILENT = 17;
POWERWORLD = 18;
PET = 19;
FLOWDEMO = 20;
GEEPC = 21;
CHAPMAN = 22;
UCTE = 23;
PCFLO = 24;
WEBFLOW = 25;
IPSS = 26;
CEPEL = 27;
ODM = 28;
REDS = 29;
VITRUVIO = 30; % all files

a = dir;
numfile = find([a.isdir] == 0);
jfile = 1;
cfile = [];
for i = 1:length(numfile)
  nomefile = a(numfile(i)).name;
  lfile = length(nomefile);
  add_file = 0;

  % display(formato)

  switch int32(formato)
   case IEEE
    extent = nomefile(max(1,lfile-2):lfile);
    if strcmpi(extent,'dat') || strcmpi(extent,'txt') || ...
          strcmpi(extent,'.cf'),
      if isfile(nomefile,'BUS DATA FOLLOW',20)
        add_file = 1;
      end
    end
   case CYME
    extent1 = nomefile(max(1,lfile-3):lfile);
    extent2 = nomefile(max(1,lfile-2):lfile);
    if strcmpi(extent1,'.nnd') || strcmpi(extent2,'.sf')
      add_file = 1;
    end
   case MATPOWER
    extent = nomefile(lfile);
    if strcmpi(extent,'m')
      if isfile(nomefile,'baseMVA',5), add_file = 1; end
    end
   case PSAT
    extent = nomefile(lfile);
    if strcmpi(extent,'m')
      if strcmp(nomefile(1),'d')
        add_file = 1;
      elseif isfile(nomefile,'Bus.con',50)
        add_file = 1;
      end
    end
   case PSATPERT
    extent = nomefile(lfile);
    if strcmpi(extent,'m')
      if strcmp(nomefile(1),'p')
        add_file = 1;
      elseif isfile(nomefile,'(t)',5)
        add_file = 1;
      end
    end
   case PSATMDL
    extent = nomefile(max(1,lfile-2):lfile);
    if strcmpi(extent,'mdl')
      if strcmpi(nomefile,'fm_lib.mdl')
        add_file = 0;
      %elseif strcmp(nomefile(1),'d')
      %  add_file = 1;
      %elseif isfile(nomefile,'PSATblock',1000) %% THIS IS TOO SLOW!!
      %  add_file = 1;
      else
        add_file = 1;
      end
    end
   case PST
    extent = nomefile(lfile);
    if strcmpi(extent,'m') && strcmp(nomefile(1),'d')
      if isfile(nomefile,'bus = [',50), add_file = 1; end
      if ~add_file
        if isfile(nomefile,'bus=',50), add_file = 1; end
      end
    end
   case EPRI
    extent = nomefile(max(1,lfile-2):lfile);
    if strcmpi(extent,'wsc') || strcmpi(extent,'txt') || ...
          strcmpi(extent,'dat')
      if isfile(nomefile,'HDG',15)
        add_file = 1;
      elseif isfile(nomefile,'/NETWORK_DATA\',20)
        add_file = 1;
      end
    end
   case PSSE
    extent = nomefile(max(1,lfile-2):lfile);
    if strcmpi(extent,'raw'),
      fid = fopen(nomefile, 'rt');
      sline = fgets(fid);
      out = 0;
      if isempty(sline), sline = '   2'; end
      if sline == -1; sline = '   2'; end
      if length(sline) == 1; sline = [sline,'   ']; end
      if isempty(str2num(sline(1:4))), sline = '   2'; end
      if str2num(sline(1:2)) == 0 || str2num(sline(1:2)) == 1
        out = 1;
      end
      if strcmp(sline(1:3),'001'), out = 0; end
      count = fclose(fid);
      if out, add_file = 1; end
    end
   case PSAP
    extent = nomefile(max(1,lfile-2):lfile);
    if strcmpi(extent,'dat'),
      fid = fopen(nomefile, 'rt');
      sline = fgets(fid);
      count = fclose(fid);
      if strfind(sline,'1'), add_file = 1; end
    end
   case EUROSTAG
    extent = nomefile(max(1,lfile-2):lfile);
    if strcmpi(extent,'dat'),
      if isfile(nomefile,'HEADER ',20), add_file = 1; end
    end
   case TH
    extent = nomefile(max(1,lfile-2):lfile);
    if strcmpi(extent,'dat'),
      if isfile(nomefile,'SYSBASE',50) || ...
            isfile(nomefile,'THLINE',50)
        add_file = 1;
      end
    end
   case CESI
    extent = nomefile(max(1,lfile-2):lfile);
    if strcmpi(extent,'dat'),
      if isfile(nomefile,'VNOM',25), add_file = 1; end
    end
   case VST
    extent = nomefile(max(1,lfile-7):lfile);
    if strcmpi(extent,'_vst.dat'), add_file = 1; end
   case SIMPOW
    extent = nomefile(max(1,lfile-6):lfile);
    %if strcmpi(extent,'.optpow') || strcmpi(extent,'.dynpow')
    if strcmpi(extent,'.optpow'), add_file = 1; end
   case IPSS
    extent1 = nomefile(max(1,lfile-7):lfile);
    extent2 = nomefile(max(1,lfile-4):lfile);
    if strcmpi(extent1,'.ipssdat') || strcmpi(extent2,'.ipss')
      add_file = 1;
    end
   case NEPLAN
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.ndt'), add_file = 1; end
   case ODM
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.odm'), add_file = 1; end
    if strcmpi(extent,'.xml')
      if isfile(nomefile,'PSSStudyCase',10), add_file = 1; end
    end
   case DIGSILENT
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.dgs'), add_file = 1; end
   case POWERWORLD
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.aux'), add_file = 1; end
   case PET
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.pet'), add_file = 1; end
   case FLOWDEMO
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.fdn'), add_file = 1; end
   case CHAPMAN
    if isempty(findstr(nomefile,'.')),
      if isfile(nomefile,'SYSTEM',10), add_file = 1; end
    end
   case UCTE
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.uct'), add_file = 1; end
   case REDS
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.pos')
      if isfile(nomefile,'.PU',10), add_file = 1; end
    end
   case PCFLO
    if strmatch('bdat.',lower(nomefile)), add_file = 1; end
   case WEBFLOW
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.txt')
      if isfile(nomefile,'BQ',10)
        add_file = 1;
      end
    end
   case CEPEL
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.txt')
      if isfile(nomefile,'TITU',5)
        add_file = 1;
      end
    end
   case GEEPC
    extent = nomefile(max(1,lfile-3):lfile);
    if strcmpi(extent,'.epc'), add_file = 1; end
   otherwise   % all files
    % add only files that do not begin with a dot that are
    % hidden files on UNIX systems
    if ~(strcmp(nomefile(1),'.') && isunix)
      add_file = 1;
    end
  end
  if add_file, cfile{jfile,1} = a(numfile(i)).name; jfile = jfile + 1; end
end

%============================================================================

function out = isfile(file,stringa,nrow)

% checking the first nrow to figure out the data format

out = 0;
[fid, message] = fopen(file, 'rt');
if ~isempty(message)
  fm_disp(['While inspecting the current folder, ', ...
           'error found in file "',file,'". ',message])
  return
end
n_row = 0;
while 1
  sline = fgets(fid);
  n_row = n_row + 1;
  if ~isempty(sline), if sline == -1, break; end, end
  vec = strfind(sline,stringa);
  if ~isempty(vec), out = 1; break, end
  if n_row == nrow, break, end
end
count = fclose(fid);


%============================================================================

function devices = getdevices

if isunix
  devices = {'/'};
else
  devices = {'a:\'};
  ndev = 1;
  for i = 99:122
    device_name = [char(i),':\'];
    %if exist(device_name) == 7
    if ~isempty(dir(device_name))
      ndev = ndev + 1;
      devices{ndev,1} = device_name;
    end
  end
end

%============================================================================
function check = fm_perl(program_name,filter_name,file_name)

global Path Fig

cmd = [Path.filters,filter_name];

% last minute option for certain filters
hdl = findobj(Fig.dir,'Tag','CheckboxSilent');
if ~get(hdl,'Value')
  switch program_name
   case 'CESI'
    [add_file,add_path] = uigetfile('*.dat','Select COLAS ADD file');
    if strcmp(add_path,[pwd,filesep])
      file_name = ['-a" "',add_file,'" "',file_name];
    elseif add_path == 0
      % no COLAS ADD file
    else
      % COLAS ADD file is not in the current folder
      fm_disp(['* * COLAS ADD file must be in the same folder as base ' ...
               'data file.'])
    end
   case 'NEPLAN'
    [add_file,add_path] = uigetfile('*.edt','Select EDT file');
    if strcmp(add_path,[pwd,filesep])
      file_name = ['-a" "',add_file,'" "',file_name];
    elseif add_path == 0
      % no NEPLAN EDT file
    else
      % NEPLAN EDT file is not in the current folder
      fm_disp(['* * NEPLAN EDT file must be in the same folder as NDT ' ...
               'file.'])
    end
   case 'SIMPOW'
    [add_file,add_path] = uigetfile('*.dynpow','Select DYNPOW file');
    if strcmp(add_path,[pwd,filesep])
      file_name = [file_name,'" "',add_file];
    elseif add_path == 0
      % no DYNPOW file
      file_name = ['-n" "',file_name];
    else
      file_name = [file_name,'" "',add_path,filesep,add_file];
    end
   otherwise
    % nothing to do
  end
end

% verbose conversion
hdl = findobj(Fig.dir,'Tag','CheckboxVerbose');
if get(hdl,'Value')
  file_name = ['-v" "',file_name];
end

if ispc
  cmdString = ['"',Path.filters,filter_name,'"  "',file_name,'"'];
else
  cmdString = [filter_name,' "',file_name,'"'];
end

% Execute Perl script
errTxtNoPerl = 'Unable to find Perl executable.';

if isempty(cmdString)
  % nothing to do ...
elseif ispc % PC
  perlCmd = fullfile(matlabroot, 'sys\perl\win32\bin\');
  cmdString = ['perl ' cmdString];
  perlCmd = ['set PATH=',perlCmd, ';%PATH%&' cmdString];
  [status, results] = dos(perlCmd);
else % UNIX
  [status, perlCmd] = unix('which perl');
  if (status == 0)
    [status, results] = unix(cmdString);
  else
    error(errTxtNoPerl);
  end
end

fm_disp(results)
check = ~status;