function fm_theme(command)
% FM_THEME set PSAT theme properties
%
% FM_THEME(COMMAND)
%      COMMAND specific setting command
%
%see also FM_THEMEFIG
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Theme Path Fig Settings

switch command
case 'apply'

  value = get(Theme.hdl(2),'Value');

  fid = fopen([Path.themes,popupstr(Theme.hdl(2))],'r');
  if fid == -1,
    fm_disp(['Can''t open file ',Path.themes,popupstr(Theme.hdl(2))],2),
    return,
  end

  while 1
    string = fgetl(fid);
    if string == -1, break, end
    eval(['Theme.',deblank(string(1:15)),' = ',string(16:end),';'])
  end

  fclose(fid);

  Theme.color01 = max(min(Theme.color01,1),0);
  Theme.color02 = max(min(Theme.color02,1),0);
  Theme.color03 = max(min(Theme.color03,1),0);
  Theme.color04 = max(min(Theme.color04,1),0);
  Theme.color05 = max(min(Theme.color05,1),0);
  Theme.color06 = max(min(Theme.color06,1),0);
  Theme.color07 = max(min(Theme.color07,1),0);
  Theme.color08 = max(min(Theme.color08,1),0);
  Theme.color09 = max(min(Theme.color09,1),0);
  Theme.color10 = max(min(Theme.color10,1),0);
  Theme.color11 = max(min(Theme.color11,1),0);

  if ~isunix && Settings.hostver >= 7 && sum(Theme.color09) < 0.3
    Theme.color09 = [0 0 0];
  end

  set(0,'DefaultUicontrolBackgroundColor',Theme.color01)

  a = fieldnames(Fig);
  for i = length(a):-1:1
    fig = getfield(Fig,a{i});
    if fig,
      name = get(fig,'FileName');
      pos = get(fig,'Position');
      close(fig)
      switch name
      case 'fm_sset', fm_comp sopen
      case 'fm_xset', fm_comp xopen
      case 'fm_pset', fm_comp popen
      otherwise, eval(name);
      end
      set(gcf,'Position',pos)
    end
  end
  set(Theme.hdl(2),'Value',value)
  figure(Fig.theme)

case 'preview'

  fid = fopen([Path.themes,popupstr(Theme.hdl(2))],'r');
  if fid == -1
    fm_disp(['Can''t open file ',Path.themes,popupstr(Theme.hdl(2))],2)
    return
  end

  while 1
    string = fgetl(fid);
    if string == -1, break, end
    eval(['T',deblank(string(1:15)),' = ',string(16:end),';'])
  end

  Tcolor01 = max(min(Tcolor01,1),0);
  Tcolor02 = max(min(Tcolor02,1),0);
  Tcolor03 = max(min(Tcolor03,1),0);
  Tcolor04 = max(min(Tcolor04,1),0);
  Tcolor05 = max(min(Tcolor05,1),0);
  Tcolor06 = max(min(Tcolor06,1),0);
  Tcolor07 = max(min(Tcolor07,1),0);
  Tcolor08 = max(min(Tcolor08,1),0);
  Tcolor09 = max(min(Tcolor09,1),0);
  Tcolor10 = max(min(Tcolor10,1),0);
  Tcolor11 = max(min(Tcolor11,1),0);

  if ~isunix && Settings.hostver >= 7 && sum(Tcolor09) < 0.3
    Tcolor09 = [0 0 0];
  end

  fclose(fid);

  set(Theme.hdl(1), 'Color',Tcolor01);
  set(Theme.hdl(4), 'BackgroundColor',Tcolor02, 'ForegroundColor',Tcolor03);
  set(Theme.hdl(5), 'BackgroundColor',Tcolor03, 'ForegroundColor',Tcolor09);
  set(Theme.hdl(6), 'BackgroundColor',Tcolor02);
  set(Theme.hdl(7), 'Color',Tcolor11);
  set(Theme.hdl(8), 'BackgroundColor',Tcolor03, 'ForegroundColor',Tcolor06, 'FontName',Tfont01);
  set(Theme.hdl(9), 'BackgroundColor',Tcolor04, 'ForegroundColor',Tcolor05, 'FontName',Tfont01);
  set(Theme.hdl(10),'BackgroundColor',Tcolor02);
  set(Theme.hdl(11),'BackgroundColor',Tcolor02);
  set(Theme.hdl(12),'BackgroundColor',Tcolor02, 'ForegroundColor',Tcolor03);
  set(Theme.hdl(13),'ForegroundColor',Tcolor07, 'BackgroundColor',Tcolor04, 'FontName',Tfont01);
  set(Theme.hdl(14),'ForegroundColor',Tcolor05, 'BackgroundColor',Tcolor04, 'FontName',Tfont01);
  set(Theme.hdl(15),'BackgroundColor',Tcolor02, 'ForegroundColor',[0 0 0]);
  set(Theme.hdl(16),'ForegroundColor',Tcolor05, 'BackgroundColor',Tcolor04, 'FontName',Tfont01);
  set(Theme.hdl(17),'ForegroundColor',Tcolor08, 'BackgroundColor',Tcolor08);
  set(Theme.hdl(18),'BackgroundColor',Tcolor08, 'ForegroundColor',[0 0 0]);
  if sum(Tcolor08) < 2, set(Theme.hdl(18),'ForegroundColor',[1 1 1]); end

case 'themes'

  a = dir([Path.themes,'*.thm']);
  set(gcbo,'String',{a.name}');

end