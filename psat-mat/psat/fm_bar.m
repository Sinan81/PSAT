function fm_bar(command)
% FM_BAR draws PSAT status bar
%
% FM_BAR(COMMAND)
%
%see also FM_MAIN
%
%Author:    Federico Milano
%Date:      25-Feb-2004
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Hdl Fig Theme Settings
persistent p1 p2

if ~ishandle(Fig.main), return, end

if isnumeric(command)
  x1 = command(1);
  x2 = command(2);
  if x1 > 0.95
    command = 'drawend';
  else
    command = 'draw';
  end
  x1 = 0.01+x1*0.98;
  x2 = 0.01+x2*0.98;
end

switch command
 case 'open'

  set(Fig.main,'Pointer','watch')
  set(0,'CurrentFigure',Fig.main);
  set(Hdl.text,'Visible','off');
  set(Hdl.frame,'Visible','off');
  if ishandle(Hdl.bar), delete(Hdl.bar); end
  Hdl.bar = axes('position',[0.04064 0.0358 0.9212 0.04361], ...
                 'box','on');

  if Settings.hostver < 8.04
    set(Hdl.bar, ...
        'Drawmode','fast', ...
        'NextPlot','add', ...
        'Color',[0.9 0.9 0.9], ...
        'Xlim',[0 1], ...
        'Ylim',[0 1], ...
        'Box','on', ...
        'XTick',[], ...
        'YTick',[], ...
        'XTickLabel','', ...
        'YTickLabel','');
  else
    set(Hdl.bar, ...
        'SortMethod','depth', ...
        'NextPlot','add', ...
        'Color',[0.9 0.9 0.9], ...
        'Xlim',[0 1], ...
        'Ylim',[0 1], ...
        'Box','on', ...
        'XTick',[], ...
        'YTick',[], ...
        'XTickLabel','', ...
        'YTickLabel','');
  end
  p1 = fill([0.01 0.01 0.01+1e-5 0.01+1e-5],[0.25 0.75 0.75 0.25], ...
             Theme.color08,'EdgeColor',Theme.color08);
  p2 = text(1e-5,0.35,[' ',num2str(round(1e-5*100)),'%']);
  if Settings.hostver < 8.04 && Settings.hostver > 8
    set(p1,'HorizontalAlignment','left');
    set(p2,'HorizontalAlignment','left');
  elseif Settings.hostver >= 7.07 && Settings.hostver < 8
    set(p1,'EraseMode','background','HorizontalAlignment','left');
    set(p2,'EraseMode','background','HorizontalAlignment','left');
  elseif Settings.hostver < 7.07
    set(p1,'EraseMode','xor','HorizontalAlignment','left');
    set(p2,'EraseMode','xor','HorizontalAlignment','left');
  end
  drawnow

 case 'draw'

  set(p2,'Position',[x1, 0.35, 0], ...
      'String',[' ',num2str(round(x1*100)),'%']);
  set(p2,'Position',[x2, 0.35, 0], ...
      'String',[' ',num2str(round(x2*100)),'%']);
  set(p1,'XData',[0.01, 0.01, x2, x2]);
  drawnow

 case 'drawend'

  set(p2,'Position',[x1, 0.35, 0], ...
         'String',[' ',num2str(round(x1*100)),'%']);
  set(p2,'HorizontalAlignment','right');
  set(p1,'XData',[x1, x1, x2, x2]);
  set(p2,'Position',[x2, 0.35, 0], ...
         'String',[' ',num2str(round(x2*100)),'%']);
  drawnow

 case 'close'

  set(Fig.main,'Pointer','arrow');
  delete(Hdl.bar);
  Hdl.bar = -1;
  set(Hdl.frame,'Visible','on');
  set(Hdl.text,'Visible','on');
  clear p1 p2

end