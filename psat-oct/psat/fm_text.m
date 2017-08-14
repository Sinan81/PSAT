function fm_text(varargin)
% FM_TEXT settings for the command history GUI
%
% FM_TEXT(VARARGIN)
%
% see also FM_HIST
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    11-Feb-2003
%Version:   1.0.2
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global History Fig Hdl Path Settings clpsat

if nargin == 1
  type = varargin{1};
elseif nargin == 2
  type = varargin{1};
  prop = varargin{2};
elseif nargin == 3
  type = varargin{1};
  prop = varargin{2};
  valu = varargin{3};
else
  fm_disp('Improper number of arguments in calling function fm_text',2)
  return
end

switch type
 case 1

  filename  = [fm_filenum('log'),'.log'];
  fid = fopen([Path.data,filename],'wt+');
  for i = 1:length(History.text)
    count = fprintf(fid,'%s\n',History.text{i});
  end
  fclose(fid);
  fm_text(13,[Path.data,filename])
  fm_disp(['Log file written in ',Path.data,filename])

 case 2

  filename  = [fm_filenum('log'),'.log'];
  fid = fopen([Path.data,filename],'wt+');
  value = get(Hdl.hist,'Value');
  for i = 1:length(value)
    count = fprintf(fid,'%s\n',History.text{value(i)});
  end
  fclose(fid);
  fm_text(13,[Path.data,filename])
  fm_disp(['Log file written in ',Path.data,filename])

 case 3

  Hdl.hist = findobj(Fig.hist,'Tag','Listbox1');
  value = get(Hdl.hist,'Value');
  History.text(value) = [];
  if isempty(History.text)
    History.text = {'    '};
  end
  set(Hdl.hist,'String',History.text)
  set(Hdl.hist,'Value',min(length(History.text),max(value)+1))
  drawnow
  History.index = 1;

 case 4

  Hdl.hist = gcbo;
  if ~isempty(History.text)
    set(gcbo,'String',History.text);
  end

 case 5  % font list

  set(Hdl.hist,prop,valu);
  if strcmp(prop,'FontName')

    tag = get(gcbo,'Tag');
    numero = str2num(tag(5:end));

    versione = version;
    if strcmp(versione(1),'6')
      numtot = length(listfonts);
    else
      numtot = 3;
    end
    ntot = fix(numtot/25)+sign(rem(numtot,25));
    ncol = fix(numero/25)+sign(rem(numero,25));

    hdlp = get(gcbo,'Parent');
    for i = 1:ncol-1, hdlp = get(hdlp,'Parent'); end
    for i = 1:ntot
      hdlc = get(hdlp,'Children');
      if i == ncol, hdlb = hdlc(end); end
      set(hdlc,'Checked','off');
      hdlp = hdlc(1);
    end

  else
    hdlp = get(gcbo,'Parent');
    hdlc = get(hdlp,'Children');
    set(hdlc,'Checked','off');
  end
  set(gcbo,'Checked','on');
  if ischar(valu)
    eval(['History.',prop,' = ''',valu,''';'])
  else
    eval(['History.',prop,' = [',num2str(valu),'];'])
  end

 case 6 % save settings

  fid = fopen([Path.psat,'history.ini'],'wt');
  s = fieldnames(History);
  slen = length(s);
  b = blanks(19);
  for i = 4:slen
    a = eval(['History.',s{i}]);
    campo = [s{i},b];
    campo = campo(1:19);
    if ischar(a)
      count = fprintf(fid,[campo,'''',a,'''']);
    elseif length(a) > 1
      count = fprintf(fid,[campo,'[',num2str(a),']']);
    else
      count = fprintf(fid,[campo,num2str(a)]);
    end
    if i < slen
      count = fprintf(fid,'\n');
    end
  end
  count = fclose(fid);
  fm_disp('Settings of command history window saved.')

 case 7   % delete all

  set(Hdl.hist,'Value',1)
  History.text = {'    '};
  set(Hdl.hist,'String',History.text)
  drawnow
  History.index = 1;

 case 8   % find string

  testo = fm_input('Find:','History Search',1,{History.string});
  testo = testo{1};
  if isempty(testo)
    return
  end
  if ~strcmp(testo,History.string),
    History.index = 0;
    History.string = testo;
  end
  fm_text(9)

 case 9   % find next

  if isempty(History.string)
    fm_text(8)
  end

  for i = History.index+1:length(History.text)
    if ~isempty(findstr(History.text{i},History.string))
      set(Hdl.hist,'Value',i,'ListboxTop',max(i-5,1))
      drawnow
      History.index = i;
      return
    end
  end
  if History.index ~= 0
    History.index = 0;
    fm_text(9)
  else
    fm_disp(['No match for text "',History.string,'".'],2)
  end

 case 10

  hdlp = get(gcbo,'Parent');
  hdlc = get(hdlp,'Children');
  set(hdlc,'Checked','off');
  set(gcbo,'Checked','on');
  set(Hdl.hist,'Max',History.Max)

 case 11

  actcol = eval(['History.',prop]);
  color = uisetcolor(actcol);
  if length(color) == 3 && color ~= actcol
    eval(['History.',prop,' = [',num2str(color),'];'])
    hdlp = get(gcbo,'Parent');
    hdlc = get(hdlp,'Children');
    set(hdlc,'Checked','off');
    set(gcbo,'Checked','on');
    set(Hdl.hist,prop,color);
  end

 case 12 % set output to workspace

  History.workspace = ~History.workspace;
  if History.workspace,
    set(gcbo,'Checked','on')
  else
    set(gcbo,'Checked','off')
  end

 case 13 % view the selected file with the proper viewer

  if clpsat.init && ~clpsat.viewrep
    return
  end

  if strcmp(prop(1:2),'~/')
    prop = [getenv('HOME'),prop(2:end)];
  end
  a5 = '';  a6 = 1;
  a1 = strcmp(Settings.tviewer, '!cat ');
  a2 = strcmp(Settings.tviewer, '!type ');
  a3 = strcmp(Settings.tviewer, '!awk ''{print}'' ');
  a4 = strcmp(Settings.tviewer, '!gawk ''{print}'' ');
  if ~(a1 || a2 || a3 || a4)
    a5 = ' &';
    a6 = 0;
  end
  if a6
    disp(['file: ''',prop,''''])
    disp(' ')
  end
  eval([Settings.tviewer,'"',prop,'"',a5]);
  if a6
    disp(blanks(3)')
  end

 case 14 % select output format

  if ~ishandle(Fig.tviewer), return, end

  hdl1 = findobj(Fig.tviewer,'Tag','PushTXT');
  hdl2 = findobj(Fig.tviewer,'Tag','PushTEX');
  hdl3 = findobj(Fig.tviewer,'Tag','PushXLS');
  hdl4 = findobj(Fig.tviewer,'Tag','PushHTM');

  switch gcbo
  case hdl1
    set(hdl1,'Value',1)
    set(hdl2,'Value',0)
    set(hdl3,'Value',0)
    set(hdl4,'Value',0)
    Settings.export = 'txt';
  case hdl2
    set(hdl1,'Value',0)
    set(hdl2,'Value',1)
    set(hdl3,'Value',0)
    set(hdl4,'Value',0)
    Settings.export = 'tex';
  case hdl3
    set(hdl1,'Value',0)
    set(hdl2,'Value',0)
    set(hdl3,'Value',1)
    set(hdl4,'Value',0)
    Settings.export = 'xls';
  case hdl4
    set(hdl1,'Value',0)
    set(hdl2,'Value',0)
    set(hdl3,'Value',0)
    set(hdl4,'Value',1)
    Settings.export = 'html';
  end

end