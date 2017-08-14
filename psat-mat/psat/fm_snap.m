function fig = fm_snap(varargin)
% FM_SNAP create GUI for Snapshot settings
%
% HDL = FM_SNAP()
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    10-Feb-2003
%Version:   1.0.2
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Fig Theme Snapshot Settings File

% check for data file
if isempty(File.data)
  fm_disp('Set a data file for editing snapshots.',2)
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

if nargin
  switch varargin{1}

   case 'cleansnap'

    if length(Snapshot) <= 1, return, end
    Snapshot(2:end) = [];
    if ~ishandle(Fig.snap), return, end
    hdl = findobj(gcf,'Tag','Listbox1');
    set(hdl,'String',{'Power Flow Results'},'Value',1);
    hdl = findobj(gcf,'Tag','EditText1');
    set(hdl,'String',num2str(Snapshot(1).time));
    hdl = findobj(gcf,'Tag','Checkbox1');
    set(hdl,'Value',1)

   case 'assignsnap'

    if Settings.locksnap, return, end
    global DAE Bus Line Demand
    idx = varargin{2};
    if isempty(idx), return, end
    if ischar(idx)
      switch idx
       case 'new'
        idx = length(Snapshot)+1;
       case 'start'
        idx = 1;
      end
      timestored = [Snapshot(:).time];
      isclose = min(abs(timestored-varargin{4}));
      if isclose < 1e-5 && strcmp(varargin{3},'Last'), return, end
      Snapshot(idx).name = varargin{3};
      Snapshot(idx).time = varargin{4};
      DAE.g = zeros(DAE.m,1);
      fm_call('load')
      glambda(Demand,varargin{4})
      Snapshot(idx).Pl = DAE.g(Bus.a);
      Snapshot(idx).Ql = DAE.g(Bus.v);
      fm_call('gen');
      glambda(Demand,varargin{4})
    else
      DAE.g = zeros(DAE.m,1);
      fm_call('load');
      Snapshot(idx).Pl = DAE.g(Bus.a);
      Snapshot(idx).Ql = DAE.g(Bus.v);
      fm_call('gen');
    end
    Snapshot(idx).y = DAE.y;
    Snapshot(idx).x = DAE.x;
    Snapshot(idx).Ybus = Line.Y;
    Snapshot(idx).Pg = DAE.g(Bus.a);
    Snapshot(idx).Qg = DAE.g(Bus.v);
    Snapshot(idx).Gy = DAE.Gy;
    Snapshot(idx).Fx = DAE.Fx;
    Snapshot(idx).Fy = DAE.Fy;
    Snapshot(idx).Gx = DAE.Gx;
    DAE.g = zeros(DAE.m,1);

    if ~ishandle(Fig.snap), return, end
    hdl = findobj(gcf,'Tag','Listbox1');
    set(hdl,'String',{Snapshot(:).name}','Value',1);
    hdl = findobj(gcf,'Tag','EditText1');
    set(hdl,'String',num2str(Snapshot(1).time));
    hdl = findobj(gcf,'Tag','Checkbox1');
    set(hdl,'Value',1)

   case 'setsnap'

    n_snap = length(Snapshot) + 1;
    a = fm_input('Snapshot time','Input new snapshot time');
    if isempty(a); return; end
    try
      tempi = eval(a{1,1});
      tempi = tempi(find(tempi > 0));
      if isempty(tempi),
        fm_disp('Snapshot time cannot be negative or zero.')
        return,
      end
      if length(tempi) == 1
        Snapshot(n_snap).time = str2num(a{1,1});
        Snapshot(n_snap).name = ['Snapshot # ',num2str(n_snap-1)];
      else
        for i = 1:length(tempi)
          Snapshot(n_snap-1+i).time = tempi(i);
          Snapshot(n_snap-1+i).name = ['Snapshot # ', num2str(n_snap-2+i)];
        end
      end
      hdl = findobj(gcf,'Tag','Listbox1');
      nomi_snap = cell(length(Snapshot),1);
      for i = 1:length(Snapshot)
        nomi_snap{i,1} =Snapshot(i).name;
        a = Snapshot(i).time;
        b(i) = a;
      end
      [b,I] = sort(b);
      Snapshot = Snapshot(I);
      for i = 2:n_snap
        Snapshot(i).name = ['Snapshot # ',num2str(i-1)];
        nomi_snap{i,1} =Snapshot(i).name;
      end
      set(hdl,'String',nomi_snap);
      set(hdl,'Value',n_snap);
      hdl = findobj(gcf,'Tag','EditText1');
      set(hdl,'String',num2str(Snapshot(n_snap).time));
    catch
      fm_disp('Invalid expression for snapshots.')
      fm_disp(lasterr)
    end

   case 'viewsnap'

    global DAE Line Bus

    if Settings.locksnap, return, end

    switch nargin
     case 1
      viewsnap = 1;
      hdl = findobj(gcf,'Tag','Listbox1');
      value = get(hdl,'Value');
     case 2
      viewsnap = varargin{2};
      [lambda,value] = max([Snapshot(:).time]);
     case 3
      viewsnap = varargin{2};
      value = varargin{3};
    end

    if isempty(Snapshot(value).y)
      fm_disp('Selected Snapshot is empty. Run simulation to fill it up.',2)
      return
    end

    DAE.y = Snapshot(value).y;
    DAE.x = Snapshot(value).x;
    Line.Y = Snapshot(value).Ybus;
    Bus.Pg = Snapshot(value).Pg;
    Bus.Qg = Snapshot(value).Qg;
    Bus.Pl = Snapshot(value).Pl;
    Bus.Ql = Snapshot(value).Ql;
    DAE.Gy = Snapshot(value).Gy;
    DAE.Fx = Snapshot(value).Fx;
    DAE.Fy = Snapshot(value).Fy;
    DAE.Gx = Snapshot(value).Gx;
    DAE.g = zeros(DAE.m,1);

    if viewsnap
      if ~isempty(strfind(Settings.xlabel,'lambda'))
        fm_stat({['lambda (', Snapshot(value).name,') = ',num2str(Snapshot(value).time)]})
      else
        fm_stat;
      end
    end

   case 'showsnap'

    hdl = findobj(gcf,'Tag','EditText1');
    value = get(gcbo,'Value');
    set(hdl,'String',num2str(Snapshot(value).time));
    hdl = findobj(gcf,'Tag','Checkbox1');
    if value == Snapshot(1).it
      set(hdl,'Value',1);
    else
      set(hdl,'Value',0);
    end

   case 'checksnap'

    global DAE Line Bus
    hdl = findobj(gcf,'Tag','Listbox1');
    value = get(hdl,'Value');

    if isempty(Snapshot(value).y)
      fm_disp(['Selected Snapshot is empty. Run simulation to fill ' ...
          'it up.'],2)
      set(gcbo,'Value',0);
      return
    end
    Snapshot(1).it = value;
    Line.Y = Snapshot(value).Ybus;
    Bus.Pg = Snapshot(value).Pg;
    Bus.Qg = Snapshot(value).Qg;
    Bus.Pl = Snapshot(value).Pl;
    Bus.Ql = Snapshot(value).Ql;
    DAE.y = Snapshot(value).y;
    DAE.x = Snapshot(value).x;
    DAE.Gy = Snapshot(value).Gy;
    DAE.Fx = Snapshot(value).Fx;
    DAE.Fy = Snapshot(value).Fy;
    DAE.Gx = Snapshot(value).Gx;

    Settings.t0 = Snapshot(value).time;
    hdl = findobj(Fig.main,'Tag','EditText3');
    set(hdl,'String',num2str(Settings.t0));
    fm_call('i');

   case 'listsnap'

    n_snap = length(Snapshot);
    nomi_snap = cell(n_snap,1);
    for i = 1:n_snap,
      nomi_snap{i,1} = Snapshot(i).name;
    end
    set(gcbo,'String',nomi_snap,'Value',1);

   case 'editsnap'

    hdl = findobj(gcf,'Tag','Listbox1');
    value = get(hdl,'Value');
    hdl = findobj(gcf,'Tag','EditText1');
    try
      tempo = eval(get(gcbo,'String'));
      if  length(tempo) > 1 || ischar(tempo)
        fm_disp(['Invalid expression for snapshot time']);
      else
        Snapshot(value).time = tempo;
        set(hdl,'String',num2str(Snapshot(value).time));
      end
    catch
      fm_disp(['"',get(gcbo,'String'), ...
          '" is an invalid expression'])
      fm_disp(lasterr)
    end

   case 'delsnap'

    hdl = findobj(gcf,'Tag','Listbox1');
    value = get(hdl,'Value');
    if value == 1
      fm_disp('Load flow results cannot be deleted',2)
      return
    end
    Snapshot(value) = [];
    if value == Snapshot(1).it, Snapshot(1).it = 1; end
    n_snap = length(Snapshot);
    nomi_snap = cell(length(Snapshot),1);
    for i = 2:n_snap
      Snapshot(i).name = ['Snapshot # ',num2str(i-1)];
    end
    for i = 1:n_snap, nomi_snap{i,1} = Snapshot(i).name; end
    set(hdl,'String',nomi_snap);
    value = min(value,n_snap);
    set(hdl,'Value',value);
    hdl = findobj(gcf,'Tag','EditText1');
    set(hdl,'String',num2str(Snapshot(value).time));
    hdl = findobj(gcf,'Tag','Checkbox1');
    if value == Snapshot(1).it, set(hdl,'Value',1); end

  end
  return
end

if Settings.locksnap
    uiwait(fm_choice(['Snapshots are currently disabled. ' ...
                      'See Advanced Settings GUI.'],2))
    return
end

if ishandle(Fig.snap), figure(Fig.snap), return, end

if strcmp(Settings.platform,'MAC')
  aligntxt = 'center';
  dm = 0.0075;
  dm2 = 0.018;
else
  aligntxt = 'left';
  dm = 0;
  dm2 = 0;
end

h0 = figure('Color',Theme.color01, ...
  'Units', 'normalized', ...
  'Colormap',[], ...
  'CreateFcn','Fig.snap = gcf;', ...
  'DeleteFcn','Fig.snap = -1;', ...
  'FileName','fm_snap', ...
  'MenuBar','none', ...
  'Name','Snapshot Editor', ...
  'NumberTitle','off', ...
  'PaperPosition',[18 180 576 432], ...
  'PaperUnits','points', ...
  'Position',sizefig(0.3914,0.4307), ...
  'Resize','on', ...
  'ToolBar','none');

% Menu File
h1 = uimenu('Parent',h0, ...
  'Label','File', ...
  'Tag','MenuFile');
h2 = uimenu('Parent',h1, ...
  'Callback','close(gcf)', ...
  'Label','Exit', ...
  'Tag','PlotSelExit', ...
  'Accelerator','x');

h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color02, ...
  'Callback','close(gcf);', ...
  'Position',[0.64371     0.11791     0.24152      0.0839+dm2], ...
  'String','Close', ...
  'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color02, ...
  'Callback','fm_snap setsnap', ...
  'Position',[0.64371     0.35072     0.24152      0.0839+dm2], ...
  'String','Set Snapshot', ...
  'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color03, ...
  'Callback','fm_snap viewsnap', ...
  'FontWeight','bold', ...
  'ForegroundColor',Theme.color09, ...
  'Position',[0.64371     0.46712     0.24152      0.0839+dm2], ...
  'String','View Report', ...
  'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color02, ...
  'ForegroundColor',Theme.color03, ...
  'Position',[0.067864    0.095238     0.43513     0.80726], ...
  'Style','frame', ...
  'Tag','Frame1');
h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color02, ...
  'HorizontalAlignment','left', ...
  'Position',[0.12375     0.81406     0.17764    0.045351], ...
  'String','Snapshot list:', ...
  'Style','text', ...
  'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color03, ...
  'Callback','fm_snap showsnap', ...
  'CreateFcn','fm_snap listsnap', ...
  'FontName',Theme.font01, ...
  'ForegroundColor',Theme.color06, ...
  'Position',[0.12375     0.16553     0.32335     0.61905], ...
  'String','Power Flow Results', ...
  'Style','listbox', ...
  'Tag','Listbox1', ...
  'Value',1);
h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color02, ...
  'ForegroundColor',Theme.color03, ...
  'Position',[0.58084     0.60771     0.35928     0.29478], ...
  'Style','frame', ...
  'Tag','Frame2');
h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color02, ...
  'HorizontalAlignment','left', ...
  'Position',[0.64271     0.81406     0.17764    0.045351], ...
  'String',Settings.xlabel, ...
  'Style','text', ...
  'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color04, ...
  'Callback','fm_snap editsnap', ...
  'CreateFcn','set(gcbo,''String'',num2str(Snapshot(1).time));', ...
  'FontName',Theme.font01, ...
  'ForegroundColor',Theme.color05, ...
  'HorizontalAlignment',aligntxt, ...
  'Position',[0.64271     0.73016-dm     0.23752    0.063492+dm], ...
  'String','0', ...
  'Style','edit', ...
  'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color02, ...
  'Callback','fm_snap checksnap', ...
  'Position',[0.64271     0.64853-dm     0.23752    0.045351], ...
  'String','Initial time', ...
  'Style','checkbox', ...
  'Tag','Checkbox1');
h1 = uicontrol('Parent',h0, ...
  'Units', 'normalized', ...
  'BackgroundColor',Theme.color02, ...
  'Callback','fm_snap delsnap', ...
  'Position',[0.64371     0.23432     0.24152      0.0839+dm2], ...
  'String','Delete Snapshot', ...
  'Tag','Pushbutton1');
if nargout > 0, fig = h0; end