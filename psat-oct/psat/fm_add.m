function [nomi,numero] = fm_add(nomi,numero,list_box,edit_text)
% FM_ADD add variables and properties when building a
%        new component
%
% [NAMES,NUMBER] = FM_ADD(NAMES,NUMBER,LISTBOX_HDL,EDITTEXT_HDL)
%
%see also FM_MAKE
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

global Algeb Buses Initl Param Servc State Fig

hdl = get(Fig.make,'UserData');
nome = strtok(get(hdl(2),'String'));
addbus = strcmp(list_box,'ListboxBuses');
if addbus
  nomi{Buses.n+1,1} = ['bus', int2str(Buses.n+1)];
  nome = nomi{Buses.n+1,1};
end

% check variable string
if isempty(nome), return, end
s0 = 'exact';
s1 = 'The string "';
s2 = '" is already used ';
s3 = ' variable list.';
s4 = 'in the ';
if ~isvarname(nome)
  fm_disp([s1,nome,'" is not a valid Matlab variable.'])
  return
end
% check if variable is already used
if strmatch(nome,Algeb.name,s0)
  fm_disp([s1,nome,s2,'as an algebraic variable.'])
  return
end
if strmatch(nome,Buses.name,s0)
  fm_disp([s1,nome,s2,'as a bus variable.'])
  return
end
if strmatch(nome,Initl.name,s0)
  fm_disp([s1,nome,s2,'as an initial variable.'])
  return
end
if strmatch(nome,Param.name,s0)
  fm_disp([s1,nome,s2,'as a parameter.'])
  return
end
if strmatch(nome,Servc.name,s0),
  fm_disp([s1,nome,s2,'as a service variable.'])
  return
end
if strmatch(nome,State.name,s0)
  fm_disp([s1,nome,s2,'as a state variable.'])
  return
end
% check for variable consistency
if any(strmatch(nome,Servc.idx,s0)) && ...
      ~strcmp(list_box,'ListboxServiceVar')
  fm_disp([s1,nome,s2,s4,'service',s3])
  return
end
if any(strmatch(nome,Algeb.idx,s0)) && ...
      ~strcmp(list_box,'ListboxAlgebraic')
  fm_disp([s1,nome,s2,s4,'algebraic',s3])
  return
end
if any(strmatch(nome,Initl.idx,s0)) && ...
      ~strcmp(list_box,'ListboxInitial')
  fm_disp([s1,nome,s2,s4,'initial',s3])
  return
end
if strcmp(nome,'null') || strcmp(nome,'None')
  fm_disp([s1,nome,'" is a protected word.'])
  return
end

% general settings
numero = numero + 1;
nomi{numero,1} = nome;
set(findobj(gcf,'Tag',list_box),'String',nomi,'Value',numero)

% other settings
switch list_box
case 'ListboxBuses'

    Algeb.idx = cell(2*numero,1);
    for i = 1:numero
        Algeb.idx{i,1} = ['V', int2str(i)];
        Algeb.idx{numero+i,1} = ['theta', int2str(i)];
    end
    set(hdl(13),'String',Algeb.idx,'Value',length(Algeb.idx));

    Servc.idx = Servc.oldidx;
    actualservice = length(Servc.idx);
    for i = 1:numero
        Servc.idx{actualservice+i,1} = ['P', int2str(i)];
        Servc.idx{actualservice+numero+i,1} = ['Q', int2str(i)];
    end
    set(hdl(14),'String',Servc.idx,'Value',length(Servc.idx));

    actualinit = length(Initl.idx);
    Initl.idx{actualinit+1,1} = ['V', int2str(i),'_0'];
    Initl.idx{actualinit+2,1} = ['theta', int2str(i),'_0'];
    Initl.idx{actualinit+3,1} = ['P', int2str(i),'_0'];
    Initl.idx{actualinit+4,1} = ['Q', int2str(i),'_0'];
    set(hdl(15),'String',Initl.idx,'Value',length(Initl.idx));

    Algeb.neq = Algeb.neq + 2;
    Algeb.eqidx{Algeb.neq-1,1} = ['P', int2str(numero)];
    Algeb.eqidx{Algeb.neq,1}   = ['Q', int2str(numero)];;
    Algeb.eq{Algeb.neq-1,1} = 'null';
    Algeb.eq{Algeb.neq,1}   = 'null';
    set(hdl(11),'String',fm_strjoin(Algeb.eqidx,'=',Algeb.eq), ...
                'Value',Algeb.neq);

case 'ListboxParameter'

    Param.type{numero,1} = 'None';
    Param.unit{numero,1} = 'None';
    Param.descr{numero,1} = 'None';

case 'ListboxState'

    State.nodyn{numero,1} = 'No';
    State.time{numero,1} = 'None';
    State.limit{numero,1} = 'None';
    State.limit{numero,2} = 'None';
    State.init{numero,1} = '0';
    State.offset{numero,1} = 'No';
    State.un{numero,1} = nome;
    State.fn{numero,1} = nome;
    State.neq = State.neq + 1;
    State.eq{State.neq,1} = 'null';
    State.eqidx{State.neq,1} = ['p(', nomi{numero,1}, ')'];

    if isempty(Initl.idx),
      Initl.idx = {[nome, '_0']};
    else
      Initl.idx{end+1,1} = [nome, '_0'];
    end

    set(hdl(10), ...
        'String',fm_strjoin(State.eqidx,' = (',State.eq,')/',State.time), ...
        'Value',State.neq);
    set(hdl(15),'String',Initl.idx,'Value',length(Initl.idx));

case 'ListboxServiceVar'

    a = strmatch(nome,Servc.idx(end-2*Buses.n+1:end-Buses.n),s0);
    b = strmatch(nome,Servc.idx(end-Buses.n+1:end),s0);
    if isempty(a), a = 0; end
    if isempty(b), b = 0; end
    if a || b, return, end

    Servc.neq = Servc.neq + 1;
    numero = Servc.neq;
    Servc.limit{numero,1} = 'None';
    Servc.limit{numero,2} = 'None';
    Servc.type{numero,1} = 'Input';
    Servc.init{numero,1} = '0';
    Servc.offset{numero,1} = 'No';
    Servc.un{numero,1} = nome;
    Servc.fn{numero,1} = nome;
    Servc.eqidx{Servc.neq,1} = nome;
    Servc.eq{Servc.neq,1} = 'null';

    if isempty(Initl.idx), Initl.idx = {[nome, '_0']};
    else Initl.idx{end+1,1} = [nome, '_0'];
    end

    set(hdl(12),'String',fm_strjoin(Servc.eqidx,'=',Servc.eq), ...
                'Value',Servc.neq);
    set(hdl(15),'String',Initl.idx,'Value',length(Initl.idx));

end