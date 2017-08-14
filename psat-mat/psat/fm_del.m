function [nomi,numero] = fm_del(nomi,numero,list_box)
% FM_DEL delete a UDM variable or function
%
% (...) = FM_DEL(...)
%
%This function is generally called by a callback within
%the FM_MAKE function
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Algeb Buses Initl Param Servc State Fig

if numero == 0; return; end

% general operations
hlist = findobj(Fig.make,'Tag',list_box);
hdl = get(Fig.make,'UserData');
delbus = strcmp(list_box,'ListboxBuses');
if delbus
    actualnum = Buses.n;
    numero = Buses.n;
else
    actualnum = get(hlist,'Value');
    nome = nomi{actualnum,1};
end
nomi(actualnum) = [];
numero = numero-1;
set(hlist,'String',nomi,'Value',1);

% other operations
switch list_box
case 'ListboxBuses'

    % algebraic variables and equations
    Algeb.idx([Buses.n 2*Buses.n]) = [];
    alg_idx = strmatch(['V',int2str(Buses.n)],Algeb.name,'exact');
    alg_idx = [alg_idx, strmatch(['theta',int2str(Buses.n)],Algeb.name,'exact')];
    Algeb.n = Algeb.n - length(alg_idx);
    Algeb.name(alg_idx) = [];
    Algeb.eqidx([Algeb.neq-1 Algeb.neq]) = [];
    Algeb.eq([Algeb.neq-1 Algeb.neq]) = [];
    Algeb.neq = Algeb.neq - 2;

    % service variables
    ser_idx = strmatch(['P',int2str(Buses.n)],Servc.idx,'exact');
    ser_idx = [ser_idx, strmatch(['Q',int2str(Buses.n)],Servc.idx,'exact')];
    Servc.idx(ser_idx) = [];
    ser_idx = strmatch(['P',int2str(Buses.n)],Servc.name,'exact');
    ser_idx = [ser_idx,strmatch(['Q',int2str(Buses.n)],Servc.name,'exact')];
    Servc.name(ser_idx) = [];
    Servc.n = Servc.n - length(ser_idx);

    % initial variables
    ini_idx = strmatch(['V',int2str(Buses.n),'_0'],Initl.idx,'exact');
    ini_idx = [ini_idx,strmatch(['theta',int2str(Buses.n),'_0'],Initl.idx,'exact')];
    ini_idx = [ini_idx,strmatch(['P',int2str(Buses.n),'_0'],Initl.idx,'exact')];
    ini_idx = [ini_idx,strmatch(['Q',int2str(Buses.n),'_0'],Initl.idx,'exact')];
    Initl.idx(ini_idx) = [];
    ini_idx = strmatch(['V',int2str(Buses.n),'_0'],Initl.name,'exact');
    ini_idx = [ini_idx,strmatch(['theta',int2str(Buses.n),'_0'],Initl.name,'exact')];
    ini_idx = [ini_idx,strmatch(['P',int2str(Buses.n),'_0'],Initl.name,'exact')];
    ini_idx = [ini_idx,strmatch(['Q',int2str(Buses.n),'_0'],Initl.name,'exact')];
    Initl.name(ini_idx) = [];
    Initl.n = Initl.n-length(ini_idx);

    % GUI settings
    if isempty(Algeb.idx), set(hdl(13),'String',' ','Value',1);
    else, set(hdl(13),'String',Algeb.idx,'Value',length(Algeb.idx));
    end
    set(hdl(6),'String',Algeb.name,'Value',Algeb.n)
    set(hdl(14),'String',Servc.idx,'Value',length(Servc.idx))
    set(hdl(7),'String',Servc.name,'Value',Servc.n)
    if isempty(Initl.idx), set(hdl(15),'String',' ','Value',1)
    else, set(hdl(15),'String',Initl.idx,'Value',1)
    end
    set(hdl(9),'String',Initl.name,'Value',max(Initl.n,1))
    if isempty(Algeb.eq), set(hdl(11),'String',Algeb.eq,'Value',1)
    else, set(hdl(11),'String',fm_strjoin(Algeb.eqidx,'=',Algeb.eq),'Value',Algeb.neq)
    end

case 'ListboxServiceVar'

    a = strmatch(nome,Servc.idx(end-2*Buses.n+1:end-Buses.n),'exact');
    b = strmatch(nome,Servc.idx(end-Buses.n+1:end),'exact');
    if isempty(a), a = 0; end
    if isempty(b), b = 0; end
    if a || b, return, end

    Servc.type(actualnum) = [];
    Servc.limit(actualnum,:) = [];
    Servc.init(actualnum) = [];
    Servc.offset(actualnum) = [];
    Servc.un(actualnum) = [];
    Servc.fn(actualnum) = [];
    ser_idx = strmatch(nome,Servc.eqidx,'exact');
    Servc.eqidx(ser_idx) = [];
    Servc.eq(ser_idx) = [];
    Servc.neq = Servc.neq - length(ser_idx);

    % initial variables
    init_idx = strmatch([nome,'_0'],Initl.name,'exact');
    Initl.name(init_idx) = [];
    Initl.n = Initl.n - 1;
    init_idx = strmatch([nome,'_0'],Initl.idx,'exact');
    Initl.idx(init_idx) = [];

    % GUI settings
    if isempty(Servc.eq), set(hdl(12),'String',Servc.eq,'Value',1)
    else, set(hdl(12),'String',fm_strjoin(Servc.eqidx,'=',Servc.eq),'Value',Servc.neq)
    end
    set(hdl(9),'String',Initl.name,'Value',max(Initl.n,1));
    if isempty(Initl.idx), set(hdl(15),'String',' ','Value',1);
    else, set(hdl(15),'String',Initl.idx,'Value',1);
    end

case 'ListboxState'

    State.limit(actualnum,:) = [];
    State.time(actualnum) = [];
    State.nodyn(actualnum) = [];
    State.init(actualnum) = [];
    State.offset(actualnum) = [];
    State.un(actualnum) = [];
    State.fn(actualnum) = [];
    State.neq = State.neq - 1;
    State.eqidx(actualnum) = [];
    State.eq(actualnum) = [];

    % initial variables
    init_idx = strmatch([nome,'_0'],Initl.name,'exact');
    Initl.name(init_idx) = [];
    Initl.n = Initl.n - 1;
    init_idx = strmatch([nome,'_0'],Initl.idx,'exact');
    Initl.idx(init_idx) = [];

    % GUI settings
    if ~State.neq, set(hdl(10),'String',State.eq,'Value',1)
    else, set(hdl(10),'String',fm_strjoin(State.eqidx,' = (',State.eq,')/',State.time),'Value',State.neq);
    end
    set(hdl(9),'String',Initl.name,'Value',max(Initl.n,1));
    if isempty(Initl.idx), set(hdl(15),'String',' ','Value',1);
    else, set(hdl(15),'String',Initl.idx,'Value',1);
    end

case 'ListboxParameter'

    Param.type(actualnum) = [];
    Param.unit(actualnum) = [];
    Param.descr(actualnum) = [];

end