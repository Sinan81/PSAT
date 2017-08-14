function fig = fm_hist()
% FM_HIST create GUI for command history
%
% HDL = FM_HIST()
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global History Fig

if ishandle(Fig.hist), figure(Fig.hist), return, end

h0 = figure('Units','normalized', ...
  'Color',[0.8 0.8 0.8], ...
  'Colormap',[], ...
  'CreateFcn','Fig.hist = gcf;', ...
  'DeleteFcn','Fig.hist = -1; Hdl.hist = -1;', ...
  'FileName','fm_hist', ...
  'MenuBar','none', ...
  'Name','Command History', ...
  'NumberTitle','off', ...
  'PaperPosition',[18 180 576 432], ...
  'PaperUnits','points', ...
  'Position',sizefig(1.2*0.5382,1.2*0.4225), ...
  'Tag','Fig1', ...
  'ToolBar','none');

h1 = uimenu('Parent',h0,'Label','File','Tag','U2');
h2 = uimenu('Parent',h1,'Callback','fm_text(6);','Label','Save Settings','Tag','S23');
set(h2,'Accelerator','s')
h2 = uimenu('Parent',h1,'Callback','close(gcf);','Label','Close','Tag','S24');
set(h2,'Separator','on','Accelerator','x')

h1 = uimenu('Parent',h0,'Label','Edit','Tag','U1');
h2 = uimenu('Parent',h1,'Callback','fm_text(1);','Label','Create text','Tag','S21');
set(h2,'Accelerator','t')
h2 = uimenu('Parent',h1,'Callback','fm_text(2);','Label','Create text (Selection)','Tag','S22');
set(h2,'Accelerator','r')

h2 = uimenu('Parent',h1,'Callback','fm_text(8)','Label','Find','Tag','S321');
set(h2,'Separator','on','Accelerator','f')
h2 = uimenu('Parent',h1,'Callback','fm_text(9)','Label','Find Next','Tag','S321');
set(h2,'Accelerator','n')

h2 = uimenu('Parent',h1,'Callback','set(Hdl.hist,''Value'',[1:length(History.text)])','Label','Select All','Tag','S5');
set(h2,'Separator','on','Accelerator','a')
h2 = uimenu('Parent',h1,'Callback','fm_text(3)','Label','Delete Selection','Tag','S6');
set(h2,'Accelerator','d')
h2 = uimenu('Parent',h1,'Callback','fm_text(7)','Label','Delete All','Tag','S6');
set(h2,'Accelerator','z')

h2 = uimenu('Parent',h1,'Callback','fm_text(12)','Label','Output to Workspace','Tag','S7','Separator','on');
if History.workspace,
    set(h2,'Checked','on')
else
    set(h2,'Checked','off')
end
h2 = uimenu('Parent',h1, 'Callback','fm_tviewer','Label','Text Viewer', 'Tag','OptionsTV','Accelerator','v');

h1 = uimenu('Parent',h0,'Label','View','Tag','U1');

% Font Type
h2 = uimenu('Parent',h1,'Label','Font Type','Tag','S11');

versione = version;
if strcmp(versione(1),'6')
  c = listfonts;
else
  c = {'courier';'helvetica';'times'};
end
if isempty(c{1}), c(1) = []; end
n = fix(length(c)/25)+sign(rem(length(c),25));

for j = 1:n
  for i = 1:min(25,length(c)-25*(j-1))
    cb = ['fm_text(5,''FontName'',''',c{i+(j-1)*25},''')'];
    tb = ['Font',num2str(i+(j-1)*25)];
    h3 = uimenu('Parent',h2,'Callback',cb,'Label',c{i+(j-1)*25},'Tag',tb);
    if strcmp(History.FontName,c{i+(j-1)*25}), set(h3,'Checked','on'); end
  end
  if length(c)-25*(j-1) > 25, h3 = uimenu('Parent',h2,'Label','more ...','Tag',tb); end
  h2 = h3;
end

% Font Size
h2 = uimenu('Parent',h1,'Label','Font Size','Tag','S12');
n = 6:2:18;
for i = 1:length(n)
  sn = num2str(n(i));
  cb = ['fm_text(5,''FontSize'',',sn,')'];
  tb = ['Size',sn];
  h3 = uimenu('Parent',h2,'Callback',cb,'Label',sn,'Tag',tb);
  if History.FontSize == n(i), set(h3,'Checked','on'); end
end

% Font Angle
h2 = uimenu('Parent',h1,'Label','Font Angle','Tag','Edituimenu7');
h3 = uimenu('Parent',h2,'Callback','fm_text(5,''FontAngle'',''normal'')','Label','Normal','Tag','Angle1');
if strcmp(History.FontAngle,'normal'), set(h3,'Checked','on'); end
h3 = uimenu('Parent',h2,'Callback','fm_text(5,''FontAngle'',''italic'')','Label','Italic','Tag','Angle2');
if strcmp(History.FontAngle,'italic'), set(h3,'Checked','on'); end
h3 = uimenu('Parent',h2,'Callback','fm_text(5,''FontAngle'',''oblique'')','Label','Oblique','Tag','Angle3');
if strcmp(History.FontAngle,'oblique'), set(h3,'Checked','on'); end

% Font Weight
h2 = uimenu('Parent',h1,'Label','Font Weight','Tag','Edituimenu8');
h3 = uimenu('Parent',h2,'Callback','fm_text(5,''FontWeight'',''normal'')','Label','Normal','Tag','Weight1');
if strcmp(History.FontWeight,'normal'), set(h3,'Checked','on'); end
h3 = uimenu('Parent',h2,'Callback','fm_text(5,''FontWeight'',''light'')','Label','Light','Tag','Weight2');
if strcmp(History.FontWeight,'light'), set(h3,'Checked','on'); end
h3 = uimenu('Parent',h2,'Callback','fm_text(5,''FontWeight'',''demi'')','Label','Demi','Tag','Weight3');
if strcmp(History.FontWeight,'demi'), set(h3,'Checked','on'); end
h3 = uimenu('Parent',h2,'Callback','fm_text(5,''FontWeight'',''bold'')','Label','Bold','Tag','Weight4');
if strcmp(History.FontWeight,'bold'), set(h3,'Checked','on'); end

% Background Color
customcol = 1;
h2 = uimenu('Parent',h1,'Label','Background Color','Tag','Edituimenu3');
cs = [1 1 1; 0.753 0.753 0.753; 0 0 0.502; 0 0.502 0; 0.502 0 0; 0.502 0.502 0.502; 0 0 0];
lb = {'White';'Gray';'Navy';'Green';'Brown';'Dark Grey';'Black'};
for i = 1:length(cs)
    cb = ['fm_text(5,''BackgroundColor'',[',num2str(cs(i,:)),'])'];
    tg = ['BColor',num2str(i)];
    h3 = uimenu('Parent',h2,'Callback',cb,'Label',lb{i},'Tag',tg);
    if History.BackgroundColor == cs(i,:), set(h3,'Checked','on'); customcol = 0; end
end
h3 = uimenu('Parent',h2,'Callback','fm_text(11,''BackgroundColor'')','Label','Custom','Tag','Fcustom');
if customcol, set(h3,'Checked','on'), end
set(h2,'Separator','on')

% Foreground Color
customcol = 1;
h2 = uimenu('Parent',h1,'Label','Foreground Color','Tag','Edituimenu4');
cs = [1 1 1; 0 0 0.6275; 1 1 0.502; 0.502 1 1; 0 1 0.502; 1 0 0; 0.753 0.753 0.753; 0 0 0];
lb = {'White';'Blue';'Yellow';'Cyan';'Green';'Red';'Gray';'Black'};
for i = 1:length(cs)
    cb = ['fm_text(5,''ForegroundColor'',[',num2str(cs(i,:)),'])'];
    tg = ['FColor',num2str(i)];
    h3 = uimenu('Parent',h2,'Callback',cb,'Label',lb{i},'Tag',tg);
    if History.ForegroundColor == cs(i,:), set(h3,'Checked','on'); customcol = 0; end
end
h3 = uimenu('Parent',h2,'Callback','fm_text(11,''ForegroundColor'')','Label','Custom','Tag','Fcustom');
if customcol, set(h3,'Checked','on'), end

% Max number of lines
h2 = uimenu('Parent',h1,...
            'Label','Number of Lines',...
            'Tag','Edituimenu5', ...
            'Separator','on');
cs = {'50'; '100'; '250'; '500'; '1000'; '2000'; '5000'};
for i = 1:length(cs)
  cb = ['History.Max = ',cs{i},'; fm_text(10)'];
  tg = ['Fmax',num2str(i)];
  h3 = uimenu('Parent',h2,...
              'Callback',cb,...
              'Label',cs{i},...
              'Tag',tg);
  if History.Max == eval(cs{i}), set(h3,'Checked','on'); end
end

h1 = uicontrol('Parent',h0, ...
               'Units','normalized', ...
               'BackgroundColor',History.BackgroundColor, ...
               'CreateFcn','fm_text(4)', ...
               'FontName',   History.FontName, ...
               'FontSize',   History.FontSize, ...
               'FontWeight', History.FontWeight, ...
               'FontAngle',  History.FontAngle, ...
               'ForegroundColor',History.ForegroundColor, ...
               'Max',201, ...
               'Position',[0 0 1 1], ...
               'String',cell(0,1), ...
               'Style','listbox', ...
               'Tag','Listbox1', ...
               'Value',length(History.text));
if nargout > 0, fig = h0; end