function fm_new
% FM_NEW open and initialize variables and global structures for UDM
%
% FM_NEW
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Comp Algeb Buses Initl Param Servc State Path Fig

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

fm_make

% GUI handles
hdl = get(Fig.make,'UserData');

% component properties
set(hdl(1),'String',Comp.name)
set(hdl(2),'String','')
set(hdl(3),'String','')

% variable listboxes
set(hdl(4),'String',Buses.name,'Value',1)
set(hdl(5),'String',State.name,'Value',1)
set(hdl(6),'String',Algeb.name,'Value',1)
set(hdl(8),'String',Param.name,'Value',1)
set(hdl(7),'String',Servc.name,'Value',1)
set(hdl(9),'String',Initl.name,'Value',1)

% equation listboxes
set(hdl(10),'String',State.eq,'Value',1)
set(hdl(11),'String',Algeb.eq,'Value',1)
set(hdl(12),'String',Servc.eq,'Value',1)

% popupmenu variables
set(hdl(13),'String',' ','Value',1)
try
    Servc.oldidx = textread([Path.psat,'service.ini'],'%s','delimiter','\n','whitespace','');
    Servc.idx = Servc.oldidx;
    set(hdl(14),'String',Servc.idx,'Value',1)
end
set(hdl(15),'String',' ','Value',1)