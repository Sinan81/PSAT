function fm_open(varargin)
% FM_OPEN open a PSAT user defined component from a script
%
% FM_OPEN by itself opens a component asking for selecting the file,
% FM_OPEN(PATH,FILE,OPTION) opens the component FILE saved in folder
% PATH.
%
%If OPTION == 1, the component is displayed in the GUI, otherwise is
%silently loaded.
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    15-Sep-2003
%Version:   1.1.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Algeb Buses Initl Param Servc State
global Fig Comp Path

if isempty(varargin)  % open the UDM file
  cd(Path.build)
  [filename, pathname] = uigetfile('*.m', 'Open UDM file');
  cd(Path.local)
  if ~pathname
    return
  else
    settings = 1;
  end
else                  % open a saved component
  pathname = varargin{1};
  filename = varargin{2};
  settings = varargin{3};
end

% store Servc structure
Servc2 = Servc;

% reset user defined component structures
Buses.n = 0;
State.n = 0;
Algeb.n = 0;
Servc.n = 0;
Param.n = 0;
Initl.n = 0;

State.neq = 0;
Algeb.neq = 0;
Servc.neq = 0;

Comp.name = '';
Comp.descr = '';
Comp.init = 0;
Comp.shunt = 1;
Comp.series = 0;

Servc.name = [];
Buses.name = [];
State.name = [];
Param.name = [];
Algeb.name = [];
Initl.name = [];
State.eq = [];
Algeb.eq = [];
Servc.eq = [];
State.eqidx = [];
Algeb.eqidx = [];
Servc.eqidx = [];
Initl.idx = [];
State.limit = [];
State.time = [];
State.nodyn = [];
Servc.limit = [];
Servc.type = [];
State.un = [];
State.fn = [];
Param.type = [];
Param.unit = [];
Param.descr = [];
Initl.idx = [];
Algeb.idx = [];
Servc.idx = [];
State.init = [];
State.offset = [];
Servc.init = [];
Servc.offset = [];
Servc.un = [];
Servc.fn = [];

% load component structures
cd(pathname)
eval(strrep(filename,'.m',''));
cd(Path.local)

% update Servc fields
Servc.idx = [Servc2.oldidx; Servc.idx(end-2*Buses.n+1:end)];

if settings

  fm_make

  % GUI handles
  hdl = get(Fig.make,'UserData');

  % Component properties
  set(hdl(1),'String',Comp.name);
  set(hdl(2),'String',' ');
  set(hdl(3),'String',' ');

  % Variable listboxes
  set(hdl(4),'String',Buses.name,'Value',1);
  set(hdl(5),'String',State.name,'Value',1);
  set(hdl(6),'String',Algeb.name,'Value',1);
  set(hdl(7),'String',Servc.name,'Value',1);
  set(hdl(8),'String',Param.name,'Value',1);
  set(hdl(9),'String',Initl.name,'Value',1);

  % Equation listboxes
  if isempty(State.eq)
    set(hdl(10),'String',State.eq,'Value',1)
  else
    set(hdl(10),'String',fm_strjoin(State.eqidx,' = (',State.eq,')/',State.time),'Value',1);
  end
  if isempty(Algeb.eq)
    set(hdl(11),'String',Algeb.eq,'Value',1)
  else
    set(hdl(11),'String',fm_strjoin(Algeb.eqidx,'=',Algeb.eq),'Value',1);
  end
  if isempty(Servc.eq)
    set(hdl(12),'String',Servc.eq,'Value',1)
  else
    set(hdl(12),'String',fm_strjoin(Servc.eqidx,'=',Servc.eq),'Value',1);
  end

  % Variable popupmenus
  if isempty(Algeb.idx)
    set(hdl(13),'String',' ','Value',1)
  else
    set(hdl(13),'String',Algeb.idx,'Value',1)
  end
  set(hdl(14),'String',Servc.idx,'Value',1)
  if isempty(Initl.idx)
    set(hdl(15),'String',' ','Value',1)
  else
    set(hdl(15),'String',Initl.idx,'Value',1)
  end

end