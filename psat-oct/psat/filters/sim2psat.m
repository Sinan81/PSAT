function  check_model = sim2psat(varargin)
% SIM2PSAT convert Simulink models into PSAT data files
%
% CHECK = SIM2PSAT
%       CHECK = 0 conversion failed
%       CHECK = 1 conversion completed
%
%see also FM_LIB, FM_SIMREP, FM_SIMSET
%
%Author:    Federico Milano
%Date:      01-Jan-2006
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2009 Federico Milano

global File Fig Settings Hdl Path Theme History

if ~nargin
  File_Data = File.data;
  Path_Data = Path.data;
else
  File_Data = varargin{1};
  Path_Data = varargin{2};
end
if ~strcmp(Path_Data(end),filesep)
  Path_Data = [Path_Data,filesep];
end

check_model = 1;

fm_disp
fm_disp('Simulink Model Conversion');
fm_disp(['Simulink File <',File_Data,'>.']);

% component names
% NB. 'Varname' must be the last element
Compnames = {'Bus','Line','Shunt','Breaker', ...
             'Fault','SW','PV','PQ','PQgen', ...
             'Mn','Pl','Fl','Lines','Twt','Syn', ...
             'Ind','Mot','Ltc','Thload','Tg','Exc', ...
             'Pss','Oxl','Hvdc','Svc','Tcsc', ...
             'Statcom','Sssc','Upfc','Mass','SSR', ...
             'Tap','Demand','Supply','Rsrv','Rmpg', ...
             'Rmpl','Vltn','Ypdp','Sofc','Cac','Spv','Spq', ...
             'Cluster','Exload','Phs','Cswt','Dfig', ...
             'Ddsg','Wind','Busfreq','Pmu','Jimma', ...
             'Mixload','Pod','Areas','Regions','Varname'};

lasterr('');
for i = 1:length(Compnames),
  eval([Compnames{i}, ' = [];']);
end
tipi = length(Compnames)-1;

% constants used in the component masks
% ----------------------------------------------------------------
on = 1;
off = 0;
omega = 1;
power = 2;
voltage = 3;
monday = 1;
tuesday = 2;
wednesday = 3;
thursday = 4;
friday = 5;
saturday = 6;
sunday = 7;
winter_week_day = 1;
winter_week_end = 2;
summer_week_day = 3;
summer_week_end = 4;
spring_fall_week_day = 5;
spring_fall_week_end = 6;
measurements = 1;
weibull = 2;
composite = 3;
mexican_hat = 4;
Bus_V = 1;
Line_P_from_bus = 2;
Line_P_to_bus = 3;
Line_I_from_bus = 4;
Line_I_to_bus = 5;
Line_Q_from_bus = 6;
Line_Q_to_bus = 7;
in = 1;
out = 1;
ins = 1;
ous = 1;
constant_voltage = 1;
constant_reactance = 2;
constant_power = 3;
constant_line_power = 1;
constant_angle = 2;
SVC_control = 1;
TCSC_control = 2;
STATCOM_control = 3;
SSSC_control = 4;
UPFC_control = 5;
Xc = 1;
Alpha = 2;
constant_admittance = 1;
constant_power_flow = 2;
Current_control = 1;
Power_control = 2;
Voltage_control = 3;

% loading Simulink model
% ----------------------------------------------------------------
File_Data = strrep(File_Data,'(mdl)','');
File_Data = strrep(File_Data,'.mdl','');
fm_disp('Loading Simulink Model')
%cd(Path_Data);
open_sys = find_system('type','block_diagram');
OpenModel = sum(strcmp(open_sys,File_Data));
if OpenModel
  cur_sys = get_param(File_Data,'Handle');
else
  localpath = pwd;
  cd(Path_Data)
  if exist(File_Data,'file') ~= 4
    fm_disp(['File <',File_Data,'> is not a Simulink model.'],2)
    check_model = 0;
    return
  end
  cur_sys = load_system(File_Data);
  cd(localpath)
end
% open status bar
fm_bar open

% load block and mask properties
% ----------------------------------------------------------------

fm_disp('   * * *')
fm_disp('Check model version and blocks ...')
SimUpdate(cur_sys)

Settings.mv = str2num(get_param(cur_sys,'ModelVersion'));
blocks = find_system(cur_sys,'Type','block');
if strcmp(get_param(cur_sys,'Open'),'on')
  hilite_system(cur_sys,'none')
end
masks = get_param(blocks,'MaskType');
nblock = length(blocks);
tipi3 = 1/(tipi + 1 + 2*nblock);
fm_bar([1e-3,tipi3])

fm_disp('   * * *')
fm_disp('Statistics ...')

vector = zeros(13,1);
vector(1) = length(find_system(blocks,'Description','Connection'));
vector(2) = length(find_system(blocks,'Description','Power Flow'));
vector(3) = length(find_system(blocks,'Description','OPF & CPF'));
vector(4) = length(find_system(blocks,'Description','Faults & Breakers'));
vector(5) = length(find_system(blocks,'Description','Loads'));
vector(6) = length(find_system(blocks,'Description','Machines'));
vector(7) = length(find_system(blocks,'Description','ULTC'));
vector(8) = length(find_system(blocks,'Description','Controls'));
vector(9) = length(find_system(blocks,'Description','FACTS'));
vector(10) = length(find_system(blocks,'Description','Sparse Dynamic Component'));
vector(11) = length(find_system(blocks,'Description','Wind Turbines'));
vector(12) = length(find_system(blocks,'Description','Measurements'));

dispno(vector(1),'Connections')
dispno(vector(2),'Power Flow Components')
dispno(vector(3),'OPF & CPF Components')
dispno(vector(4),'Faults & Breakers')
dispno(vector(5),'Special Loads')
dispno(vector(6),'Machines')
dispno(vector(7),'Regulating Transformers')
dispno(vector(8),'Controls')
dispno(vector(9),'FACTS')
dispno(vector(10),'Spare Dynamic Components')
dispno(vector(11),'Wind Power Components')
dispno(vector(12),'Measurement Components')

% component data matrices
% ----------------------------------------------------------------

fm_disp('  * * *')
fm_disp('Definition of component data ...')

kinds = zeros(length(Compnames),1);
idx_old = 0;
for i = 1:nblock
  tipo = masks{i};
  idx = strmatch(tipo,Compnames,'exact');
  if ~isempty(idx)
    kinds(idx) = kinds(idx)+1;
    sidx = num2str(kinds(idx));

    if idx ~= idx_old
      idx_old = idx;
      fm_disp(['Data "',tipo,'.con"'])
    end

    comp_data = get_param(blocks(i),'MaskVariables');
    comp_value = get_param(blocks(i),'MaskValueString');
    valori = strrep(['[',comp_value,']'],'|',',');
    indici = comp_data;
    if strmatch(indici,'pxq=@1;','exact')
      indici = ':';
    else
      indici = ['[',indici,']'];
      indici = strrep(indici,'x',':');
      indici = strrep(indici,'p','');
      indici = strrep(indici,'_',' ');
      indici = strrep(indici,'q','');
    end
    indici = regexprep(indici,'=@([0-9]*);',' ');
    try
      eval([tipo,'(',sidx,',',indici,') = ',valori,';']);
    catch
      %[tipo,'(',sidx,',',indici,') = ',valori,';']
      fm_disp(['Error: ',tipo,' block <', ...
          get_param(blocks(i),'Name'), ...
          '> has a wrong number of data.'],2)
      hilite_system(blocks(i),'default')
      eval([tipo,'(',sidx,',',indici,') = 0;']);
    end
    set_param(blocks(i),'UserData',sidx);
  end
  if ~rem(i,5), fm_bar([(i-1)*tipi3,i*tipi3]), end

end

% "Bus" number
% ----------------------------------------------------------------
busidx = find(strcmp(masks,'Bus'));
busname = get_param(blocks(busidx),'Name');
Bus_n = length(busidx);
Bus(:,1) = [1:Bus_n]';

fm_disp('   * * *')
fm_disp('Definition of system connections ...')
for i = 1:nblock

  if isempty(masks{i}), continue, end
  if strcmp(get_param(blocks(i),'Description'),'Connection')
    continue
  end

  rowno = get_param(blocks(i),'UserData');

  % define connections
  switch masks{i}
   case {'Exc','Tg','Mass'}
    Destin = {'Syn'};
    dst = 1;  posdst = 1;
    Source = '';
    src = [];  possrc = [];
   case {'Pss','Oxl'}
    Destin = {'Exc'};
    dst = 1; posdst = 1;
    Source = '';
    src = []; possrc = [];
   case 'Rmpg'
    Destin = {'Supply'};
    dst = 1; posdst = 1;
    Source = '';
    src = []; possrc = [];
   case 'Rmpl'
    Destin = '';
    dst = []; posdst = [];
    Source = {'Demand'};
    src = 1; possrc = 1;
   case 'Breaker'
    Destin = {'Bus'};
    dst = 2; posdst = 2;
    Source = {'Line'};
    src = 1; possrc = 1;
   case 'Pod'
    Destin = {'Statcom','Sssc','Svc','Upfc','Tcsc','Dfig'};
    dst = 2; posdst = 2;
    MaskValues = get_param(blocks(i),'MaskValues');
    if strcmp(MaskValues{1},'Bus_V')
      Source = {'Bus'};
    else
      Source = {'Line'};
    end
    src = 1; possrc = 1;
   case 'Cluster'
    Source = {'Cac'};
    src = 1; possrc = 1;
    Destin = {'Exc','Svc'};
    dst = 2; posdst = 2;
   case {'PV','SW','Supply','Rsrv','Rmpg','Vltn', ...
         'SSR','Sofc','PQgen','Syn','Supply','Spv','Spq'}
    Destin = {'Bus'};
    dst = 1; posdst = 1;
    Source = '';
    src = []; possrc = [];
   case {'Line','Lines','Phs','RLC','Hvdc'}
    Destin = {'Bus'};
    dst = 2; posdst = 2;
    Source = {'Bus'};
    src = 1; possrc = 1;
   case {'Sssc','Upfc','Tcsc'}
    Destin = '';
    dst = []; posdst = [];
    Source = {'Line'};
    src = 1; possrc = 1;
   case 'Ltc'
    MaskValues = get_param(blocks(i),'MaskValues');
    if strcmp(MaskValues{3},'3')
      Destin = {'Bus'};
      dst = 3; posdst = 2;
      Source = {'Bus'};
      src = [1 2]; possrc = [15 1];
    else
      Destin = {'Bus'};
      dst = 2; posdst = 2;
      Source = {'Bus'};
      src = 1; possrc = 1;
    end
   case {'Cswt','Dfig','Ddsg'}
    Destin = {'Bus'};
    dst = 2; posdst = 1;
    Source = {'Wind'};
    src = 1; possrc = 2;
   case 'Twt'
    Destin = {'Bus'};
    dst = [2 3]; posdst = [2 3];
    Source = {'Bus'};
    src = 1; possrc = 1;
   %case {'SAE1','SAE2','SAE3'}
   % Source = {'Bus'};
   % src = [1 2]; possrc = [1 2];
   % Destin = '';
   % dst = []; posdst = [];
   case {'Ypdp','Wind','Varname'}
    Source = '';
    src = []; possrc = [];
    Destin = '';
    dst = []; posdst = [];
   case {'Areas','Regions'}
    Source = '';
    src = []; possrc = [];
    MaskValues = get_param(blocks(i),'MaskValues');
    if strcmp(MaskValues{1},'1')
      Destin = {'Bus'};
      dst = 1; posdst = 2;
    else
      Destin = '';
      dst = []; posdst = [];
    end
   otherwise
    Destin = '';
    dst = []; posdst = [];
    Source = {'Bus'};
    src = 1; possrc = 1;
  end

  % find connections
  for j = 1:length(dst)
    block2_handle = SeekDstBlock(blocks(i),Destin,dst(j));
    busno = get_param(block2_handle,'UserData');
    eval([masks{i},'(',rowno,',',num2str(posdst(j)),') = ',busno,';']);
    if strcmp(masks(i),'Cluster')
      switch get_param(block2_handle,'MaskType')
       case 'Exc', ctype = '1';
       case 'Svc', ctype = '2';
      end
      eval([masks{i},'(',rowno,',3) = ',ctype,';']);
    end
    if strcmp(masks(i),'Pod')
      switch get_param(block2_handle,'MaskType')
       case 'Svc',     ctype = '1';
       case 'Tcsc',    ctype = '2';
       case 'Statcom', ctype = '3';
       case 'Sssc',    ctype = '4';
       case 'Upfc',    ctype = '5';
       case 'Dfig',    ctype = '6';
      end
      eval([masks{i},'(',rowno,',4) = ',ctype,';']);
    end
  end
  for j = 1:length(src)
    block2_handle = SeekSrcBlock(blocks(i),Source,src(j));
    busno = get_param(block2_handle,'UserData');
    eval([masks{i},'(',rowno,',',num2str(possrc(j)),') = ',busno,';']);
  end

  fm_bar([(nblock+i-1)*tipi3,(nblock+i)*tipi3])

end

fm_disp('   * * *')

% writing data file
idx1 = strmatch('Definition of component data ...',History.text);
idx2 = strmatch('Definition of system connections ...',History.text);
idx3 = strmatch('Error:',History.text);
if isempty(idx3), idx3 = 0; end
if idx3(end) > idx1(end)
  if idx3(end) > idx2(end),
    message = 'Simulink model is not well-formed (check links).';
  end
  if find(idx3 < idx2(end) & idx3 > idx1(end)),
    message = ['Component data are not well-formed (check ' ...
        'masks).'];
  end
else
  File_Data = [File_Data,'_mdl'];
  [fid, message] = fopen([Path_Data,File_Data,'.m'], 'wt');
end
if ~isempty(message),
  if strcmp(message, ...
      ['Sorry. No help in figuring out the problem ...']),
    fm_disp(['Most likely the folder "',Path_Data, ...
        '" is read only. Try to change the permission.'])
  else
    fm_disp(['Failed conversion from Simulink model: ',message],2)
  end
  if ishandle(Fig.main)
    set(Fig.main,'Pointer','arrow');
    delete(Hdl.bar); Hdl.bar = 0;
    set(Hdl.frame,'Visible','on');
    set(Hdl.text,'Visible','on');
  end
  check_model = 0;
  return
else
  fm_disp('Writing Data File',1)
end

fm_bar([(2*nblock)*tipi3,(2*nblock+1)*tipi3])

for j = 1:length(Compnames)-1
  values = eval(Compnames{j});
  if ~isempty(values)
    count = fprintf(fid,'%s.con = [ ... \n',Compnames{j});
    for i = 1:length(values(:,1))
      count = fprintf(fid,['  ',regexprep(num2str(values(i,:)),'\s*','  '),';\n']);
    end
    count = fprintf(fid,' ];\n\n');
  end
  fm_bar([(2*nblock+j-1)*tipi3,(2*nblock+j)*tipi3])
end

% count = fprintf(fid, 'Bus.names = {... \n  ');
% for i = 1:Bus_n-1
%   namebus = strrep(busname{i,1},char(10),' ');
%   count = fprintf(fid, ['''',namebus,'''; ']);
%   if rem(i,5) == 0; count = fprintf(fid,'\n  '); end
% end
% if iscell(busname)
%   namebus = strrep(busname{length(busname),1},char(10),' ');
%   count = fprintf(fid, ['''',namebus,'''};\n\n']);
% else
%   namebus = strrep(busname,char(10),' ');
%   count = fprintf(fid, ['''',namebus,'''};\n\n']);
% end

WriteNames(fid,'Bus',busname);

areaidx = find(strcmp(masks,'Areas'));
areaname = get_param(blocks(areaidx),'Name');
WriteNames(fid,'Areas',areaname);

zoneidx = find(strcmp(masks,'Regions'));
zonename = get_param(blocks(zoneidx),'Name');
WriteNames(fid,'Regions',zonename);

% print indexes of variables to be plotted
if ~isempty(Varname)
  count = fprintf(fid, 'Varname.idx = [... \n');
  nidx = length(Varname);
  count = fprintf(fid,'%5d; %5d; %5d; %5d; %5d; %5d; %5d;\n',Varname);
  if rem(nidx,7) ~= 0,
    count = fprintf(fid,'\n');
  end
  count = fprintf(fid,'   ];\n');
end

% closing data file
count = fclose(fid);
exist(File_Data);

% closing Simulink model
if ~OpenModel && ~strcmp(get_param(cur_sys,'Dirty'),'on')
  close_system(cur_sys);
end

fm_disp(['Construction of Data File <',File_Data,'.m> completed.'])

% close status bar
fm_bar close

% last operations
% cd(Path.local);
if Settings.beep, beep, end
if ~nargin, File.data = [File_Data(1:end-4),'(mdl)']; end

%------------------------------------------------------------------
function dispno(num,msg)
%------------------------------------------------------------------
if num, fm_disp([msg,': #',num2str(num),'#']), end

%------------------------------------------------------------------
function block_name = MaskType(block_handle)
%------------------------------------------------------------------

block_name = get_param(block_handle,'MaskType');
if isempty(block_name)
  block_name = get_param(block_handle,'BlockType');
end
if isempty(block_name)
  hilite_system(block_handle)
  block_name = 'Error';
  return
end
if iscell(block_name)
  block_name = block_name{1};
end

%------------------------------------------------------------------
function hdl2 = SeekDstBlock(hdl1,name2,pos)
%------------------------------------------------------------------

ports = get_param(hdl1,'PortConnectivity');

if length(ports) < pos
  SimWarnMsg(hdl1,'has the wrong number of ports')
  hdl2 = hdl1; % to avoid errors in evaluating UserData
  return
end
handles = [ports.DstBlock];
try
  idx = find(strcmp({ports.Type},'RConn1'));
  if isempty(idx), idx = pos; end
  if idx(pos) ~= pos
    hdl2 = ports(idx(pos)).DstBlock;
  else
    hdl2 = handles(pos);
  end
catch
  hdl2 = ports(pos).DstBlock;
end
hdl0 = hdl1;

while 1

  switch MaskType(hdl2)
   case name2
    break
   case 'Outport'
    port_no = str2num(get_param(hdl2,'Port'));
    ports = get_param(hdl2,'PortConnectivity');
    hdl0 = hdl2;
    hdl2 = ports(port_no).DstBlock;
   case 'PMIOPort'
    port_no = str2num(get_param(hdl2,'Port'));
    ports = get_param(hdl2,'PortConnectivity');
    hdl0 = hdl2;
    hdl2 = ports(port_no).DstBlock;
   case 'SubSystem'
    ports = get_param(hdl2,'PortConnectivity');
    port_no = num2str(find([ports(:).SrcBlock] == hdl1));
    if isempty(port_no)
      port_no = num2str(find([ports(:).DstBlock] == hdl1));
    end
    hdl0 = hdl2;
    hdl2 = find_system(hdl2,'SearchDepth',1,'Port',port_no);
   case 'Goto'
    tag = get_param(hdl2,'GotoTag');
    name = find_system(gcs,'BlockType','From','GotoTag',tag);
    from = get_param(name{1},'Handle');
    ports = get_param(from,'PortConnectivity');
    hdl0 = hdl2;
    hdl2 = ports(1).DstBlock;
   case 'Link'
    ports = get_param(hdl2,'PortConnectivity');
    if sum(strcmp(MaskType(hdl1),{'Pod','Cluster'}))
      if strcmp(ports(3).DstBlock,'Bus')
        hdl0 = hdl2;
        hdl2 = ports(2).DstBlock; % Input Port
      else
        hdl0 = hdl2;
        hdl2 = ports(3).DstBlock; % Output Port
      end
    elseif strcmp(MaskType(hdl0),MaskType(ports(2).DstBlock))
      hdl0 = hdl2;
      hdl2 = ports(3).DstBlock; % Output Port
    else
      hdl0 = hdl2;
      hdl2 = ports(2).DstBlock; % Input Port
    end
   case 'Line'
    switch MaskType(hdl1)
     case {'Breaker','Upfc','Tcsc','Sssc'}
      hdl0 = hdl2;
      hdl2 = SeekSrcBlock(hdl1,'Bus',1);
     otherwise
      SimWarnMsg(hdl1,'cannot be connected to',hdl2)
    end
    break
   case {'Breaker','Sssc','Upfc','Tcsc','Mass'}
    ports = get_param(hdl2,'PortConnectivity');
    hdl_temp = hdl0;
    hdl0 = hdl2;
    hdl2 = ports(2).DstBlock; % Output Port
    if hdl2 == hdl_temp
      hdl2 = ports(1).DstBlock; % Output Port
    end
   case 'Link2'
    ports = get_param(hdl2,'PortConnectivity');
    hdl0 = hdl2;
    hdl2 = ports(3).DstBlock; % Output Port
   case 'Error'
    SimWarnMsg(hdl1,'is badly connected')
    hdl0 = hdl2;
    hdl2 = hdl1; % to avoid errors in evaluating UserData
    break
   otherwise
    SimWarnMsg(hdl1,'cannot be connected to',hdl2)
    break
  end

end

%------------------------------------------------------------------
function hdl2 = SeekSrcBlock(hdl1,name2,pos)
%------------------------------------------------------------------
ports = get_param(hdl1,'PortConnectivity');

if length(ports) < pos
  SimWarnMsg(hdl1,'has the wrong number of ports')
  hdl2 = hdl1; % to avoid errors in evaluating UserData
  return
end

switch ports(pos).Type
 case {'1','enable'}
  hdl2 = ports(pos).SrcBlock;
 otherwise
  hdl2 = ports(pos).DstBlock;
end
hdl0 = hdl1;
while 1
  switch MaskType(hdl2)
   case name2
    break
   case 'Inport'
    port_no = str2num(get_param(hdl2,'Port'));
    ports = get_param(hdl2,'PortConnectivity');
    hdl0 = hdl2;
    hdl2 = ports(port_no).SrcBlock;
   case 'PMIOPort'
    port_no = str2num(get_param(hdl2,'Port'));
    ports = get_param(hdl2,'PortConnectivity');
    hdl0 = hdl2;
    hdl2 = ports(port_no).DstBlock;
   case 'SubSystem'
    ports = get_param(hdl2,'PortConnectivity');
    port_no = num2str(find([ports(:).DstBlock] == hdl1));
    hdl0 = hdl2;
    hdl2 = find_system(hdl2,'SearchDepth',1,'Port',port_no);
   case 'From'
    tag = get_param(hdl2,'GotoTag');
    name = find_system(gcs,'BlockType','Goto','GotoTag',tag)
    goto = get_param(name{1},'Handle');
    ports = get_param(goto,'PortConnectivity');
    hdl0 = hdl2;
    hdl2 = ports(1).SrcBlock;
   case 'Link'
    ports = get_param(hdl2,'PortConnectivity');
    if strcmp(MaskType(hdl0),MaskType(ports(2).DstBlock))
      hdl0 = hdl2;
      hdl2 = ports(3).DstBlock; % Output Port
    else
      hdl0 = hdl2;
      hdl2 = ports(2).DstBlock; % Input Port
    end
   case 'Bus'
    switch MaskType(hdl1)
     case {'Breaker','Sssc','Upfc','Tcsc'}
      hdl0 = hdl2;
      hdl2 = SeekDstBlock(hdl1,'Line',2);
     otherwise
      SimWarnMsg(hdl1,'cannot be connected to',hdl2)
    end
    break
   case {'Breaker','Sssc','Upfc','Tcsc'}
    ports = get_param(hdl2,'PortConnectivity');
    hdl_temp = hdl0;
    hdl0 = hdl2;
    hdl2 = ports(1).DstBlock; % Output Port
    if hdl2 == hdl_temp
      hdl2 = ports(2).DstBlock; % Output Port
    end
   case 'Link2'
    ports = get_param(hdl2,'PortConnectivity');
    hdl0 = hdl2;
    if strcmp(MaskType(hdl1),'Pod')
      if strcmp(MaskType(ports(2).DstBlock),name2)
        hdl2 = ports(2).DstBlock; % Input Port
        break
      elseif strcmp(MaskType(ports(3).DstBlock),name2)
        hdl2 = ports(3).DstBlock; % Output Port
        break
      else
        % try to follow one path (50% likely to succeed)
        hdl2 = ports(3).DstBlock; % Output Port
      end
    else
      hdl2 = ports(2).DstBlock; % Input Port
    end
   case 'Error'
    SimWarnMsg(hdl1,'is badly connected')
    hdl0 = hdl2;
    hdl2 = hdl1; % to avoid errors in evaluating UserData
    break
   otherwise
    SimWarnMsg(hdl1,'cannot be connected to',hdl2)
    break
  end
end

%------------------------------------------------------------------
function SimWarnMsg(varargin)
%------------------------------------------------------------------

handle1 = varargin{1};
msg = varargin{2};
hilite_system(handle1,'default')
name1 = get_param(handle1,'Name');

if nargin == 2
  fm_disp(['Error: Block <',name1,'> ',msg,'.'])
elseif nargin == 3
  handle2 = varargin{3};
  name2 = get_param(handle2,'Name');
  fm_disp(['Error: Block <',name1,'> ',msg,' block <',name2,'>.'])
end

%------------------------------------------------------------------
function WriteNames(fid,type,names)
%------------------------------------------------------------------

if isempty(names), return, end
n = length(names);
count = fprintf(fid, [type,'.names = {... \n  ']);
for i = 1:n-1
  name = strrep(names{i,1},char(10),' ');
  count = fprintf(fid, ['''',name,'''; ']);
  if rem(i,5) == 0; count = fprintf(fid,'\n  '); end
end
if iscell(names)
  name = strrep(names{n,1},char(10),' ');
  count = fprintf(fid, ['''',name,'''};\n\n']);
else
  name = strrep(names,char(10),' ');
  count = fprintf(fid, ['''',name,'''};\n\n']);
end

%------------------------------------------------------------------
function SimUpdate(sys)
%------------------------------------------------------------------

global Settings

sys = getfullname(sys);
hilite_system(sys,'none')
block = find_system(sys,'Type','block');
mask = get_param(block,'MaskType');
nblock = length(block);

% check if all blocks belong to the PSAT Library

Tags = get_param(block,'Tag');
BlockTypes = get_param(block,'BlockType');
idx = ones(nblock,1);
idx(strmatch('PSATblock',Tags,'exact')) = 0;
idx(strmatch('SubSystem',BlockTypes,'exact')) = 0;
idx(strmatch('PMIOPort',BlockTypes,'exact')) = 0;

if sum(idx)
  idx = find(idx);
  fm_disp(fm_strjoin('* * Warning: Block <',get_param(block(idx),'Name'), ...
		 '> does not belong to the PSAT Simulink Library.'))
  Settings.ok = 0;
  uiwait(fm_choice(['Some blocks do not seem to belong to the ', ...
		    'PSAT library, but could be old blocks. ', ...
		    'Do you want to fix them?']))
  if Settings.ok
    for iii = 1:length(idx)
      blocktype = mask{idx(iii)};
      if isempty(blocktype)
	blocktype = get_param(block{idx(iii)},'BlockType');
      end
      switch blocktype
       case {'Bus','Link','Goto','From'}
	prop = 'Connection';
       case {'Supply','Demand','Rmpg','Rrsv','Vltn','Rmpl','Ypdp'}
	prop = 'OPF & CPF';
       case {'Breaker','Fault'}
	prop = 'Faults & Breakers';
       case 'Busfreq'
	prop = 'Measurements';
       case {'Mn','Pl','Thload','Fl','Exload'}
	prop = 'Loads';
       case {'Syn','Ind','Mot'}
	prop = 'Machines';
       case {'Ltc','Tap'}
	prop = 'ULTC';
       case 'Phs'
	prop = 'Phase Shifter';
       case {'Tg','Exc','Cac','Cluster','Pss','Oxl'}
	prop = 'Controls';
       case {'Statcom','Upfc','Svc','Hvdc','Tcsc','Sssc'}
	prop = 'FACTS';
       case {'Dfig','Cswt','Ddsg'}
	prop = 'Wind Turbines';
       case {'Sofc','SSR','RLC','Mass','Spv','Spq'}
	prop = 'Sparse Dynamic Component';
       %case {'SAE1','SAE2','SAE3'}
       % prop = 'SAE';
       otherwise
	prop = 'Power Flow';
      end
      set_param(block{idx(iii)}, ...
		'Tag','PSATblock', ...
		'Description',prop)
    end
    save_system(sys);
  end
else
  fm_disp(' ')
  fm_disp('* * All blocks belong to the PSAT-Simulink Library.')
end

% check for old models

slackbus = find_system(sys,'MaskType','SW');
ports = get_param(slackbus,'Ports');

if isempty(ports)
  fm_disp('* * * Error: No Slack bus found!')
  pvbus = find_system(sys,'MaskType','PV');
  ports = get_param(pvbus,'Ports');
end

if isempty(ports)
  check = 1;
  fm_disp('* * Error: No connections found!')
elseif iscell(ports)
  check = sum(ports{1});
elseif isnumeric(ports)
  check = sum(ports);
end

% check if model needs to be updated
if ~check
  disp(' ')
  fm_disp('* * Warning: The model refers to an old PSAT-Simulink')
  fm_disp('             library. PSAT will try to update models.')
  disp(' ')
  Settings.ok = 0;
  uiwait(fm_choice(['The model refers to an old PSAT-Simulink ' ...
                    'library. Update?'],1))
  if ~Settings.ok, return, end
else
  return
end

load_system('fm_lib');
open_system(sys);

for i = 1:nblock

  % fix source block if it has changed
  try
    source = get_param(block{i},'SourceBlock');
    switch source
     case 'fm_lib/Power Flow/Transf5'
      set_param(block{i},'SourceBlock','fm_lib/Power Flow/Twt')
     case ['fm_lib/Wind',char(10),'Turbines/Cswt1']
      set_param(block{i},'SourceBlock',['fm_lib/Wind',char(10),'Turbines/Cswt'])
     case ['fm_lib/Wind',char(10),'Turbines/Dfig1']
      set_param(block{i},'SourceBlock',['fm_lib/Wind',char(10),'Turbines/Ddsg'])
     case ['fm_lib/Wind',char(10),'Turbines/Dfig2']
      set_param(block{i},'SourceBlock',['fm_lib/Wind',char(10),'Turbines/Dfig'])
     case ['fm_lib/Wind',char(10),'Turbines/Wind1']
      set_param(block{i},'SourceBlock',['fm_lib/Wind',char(10),'Turbines/Wind'])
     case 'fm_lib/Power Flow/Extra Line'
      set_param(block{i},'SourceBlock','fm_lib/Power Flow/Lines')
     case 'fm_lib/Power Flow/PQ1'
      set_param(block{i},'SourceBlock','fm_lib/Power Flow/PQgen')
     case 'fm_lib/Machines/Gen'
      set_param(block{i},'SourceBlock','fm_lib/Machines/Syn')
     case 'fm_lib/ULTC/LTC'
      set_param(block{i},'SourceBlock','fm_lib/ULTC/Ltc')
     case 'fm_lib/ULTC/OLTC'
      set_param(block{i},'SourceBlock','fm_lib/ULTC/Tap')
     case 'fm_lib/ULTC/PHS'
      set_param(block{i},'SourceBlock','fm_lib/ULTC/Phs')
     case 'fm_lib/Others/SOFC'
      set_param(block{i},'SourceBlock','fm_lib/Others/Sofc')
     case 'fm_lib/Others/SSR'
      set_param(block{i},'SourceBlock','fm_lib/Others/Ssr')
     case 'fm_lib/Measurements/SPV'
      set_param(block{i},'SourceBlock','fm_lib/Others/Spv')
     case 'fm_lib/Measurements/SPQ'
      set_param(block{i},'SourceBlock','fm_lib/Others/Spq')
     case 'fm_lib/Measurements/PMU'
      set_param(block{i},'SourceBlock','fm_lib/Measurements/Pmu')
     case 'fm_lib/Loads/FDL'
      set_param(block{i},'SourceBlock','fm_lib/Loads/Fl')
     case 'fm_lib/Loads/LRL'
      set_param(block{i},'SourceBlock','fm_lib/Loads/Exload')
     case 'fm_lib/Loads/TCL'
      set_param(block{i},'SourceBlock','fm_lib/Loads/Thload')
     case 'fm_lib/Loads/Mixed'
      set_param(block{i},'SourceBlock','fm_lib/Loads/Mixload')
     case 'fm_lib/Loads/VDL'
      set_param(block{i},'SourceBlock','fm_lib/Loads/Mn')
     case 'fm_lib/Loads/ZIP'
      set_param(block{i},'SourceBlock','fm_lib/Loads/Pl')
     case 'fm_lib/FACTS/HVDC'
      set_param(block{i},'SourceBlock','fm_lib/FACTS/Hvdc')
     case 'fm_lib/FACTS/SSSC'
      set_param(block{i},'SourceBlock','fm_lib/FACTS/Sssc')
     case 'fm_lib/FACTS/SVC (1)'
      set_param(block{i},'SourceBlock','fm_lib/FACTS/Svc')
     case 'fm_lib/FACTS/SVC (2)'
      set_param(block{i},'SourceBlock','fm_lib/FACTS/Svc2')
     case 'fm_lib/FACTS/StatCom'
      set_param(block{i},'SourceBlock','fm_lib/FACTS/Statcom')
     case 'fm_lib/FACTS/TCSC (1)'
      set_param(block{i},'SourceBlock','fm_lib/FACTS/Tcsc')
     case 'fm_lib/FACTS/TCSC (2)'
      set_param(block{i},'SourceBlock','fm_lib/FACTS/Tcsc2')
     case 'fm_lib/FACTS/UPFC'
      set_param(block{i},'SourceBlock','fm_lib/FACTS/Upfc')
     case 'fm_lib/Connections/Link'
      set_param(block{i},'SourceBlock','fm_lib/Connections/Link1')
     case 'fm_lib/OPF & CPF/RMPG'
      set_param(block{i},'SourceBlock','fm_lib/OPF & CPF/Rmpg')
     case 'fm_lib/OPF & CPF/RMPL'
      set_param(block{i},'SourceBlock','fm_lib/OPF & CPF/Rmpl')
     case 'fm_lib/OPF & CPF/RSRV'
      set_param(block{i},'SourceBlock','fm_lib/OPF & CPF/Rsrv')
     case 'fm_lib/OPF & CPF/VLTN'
      set_param(block{i},'SourceBlock','fm_lib/OPF & CPF/Vltn')
     case 'fm_lib/OPF & CPF/YPDP'
      set_param(block{i},'SourceBlock','fm_lib/OPF & CPF/Ypdp')
     case 'fm_lib/OPF & CPF/YPDP1'
      set_param(block{i},'SourceBlock','fm_lib/OPF & CPF/Ypdp1')
     case 'fm_lib/Controls/AVR'
      set_param(block{i},'SourceBlock','fm_lib/Controls/Exc')
     case 'fm_lib/Controls/TG'
      set_param(block{i},'SourceBlock','fm_lib/Controls/Tg')
     case 'fm_lib/Controls/SSCL'
      set_param(block{i},'SourceBlock','fm_lib/Controls/Pod')
     case 'fm_lib/Controls/OXL'
      set_param(block{i},'SourceBlock','fm_lib/Controls/Oxl')
     case 'fm_lib/Controls/PSS'
      set_param(block{i},'SourceBlock','fm_lib/Controls/Pss')
     case 'fm_lib/Controls/CAC'
      set_param(block{i},'SourceBlock','fm_lib/Controls/Cac')
     case 'fm_lib/Controls/Shaft'
      set_param(block{i},'SourceBlock','fm_lib/Others/Mass')
    end
    mask{i} = get_param(block{i},'MaskType');
  catch
    % the source block has not changed
  end

  switch mask{i}
   case {'Bus','Link','Line','Lines','Breaker','Twt' ...
         'Phs','Tcsc','Sssc','Upfc','Hvdc','Dfig', ...
         'Cswt','Ddsg','RLC','PV','SW','PQgen','Spv','Spq', ...
         'Rmpg','Rsrv','Vltn','Wind','Sofc','Ssr', ...
         'PQ','Shunt','Rmpl','Fault','Mn','Pl','Ind','Mot', ...
         'Fl','Exload','Mixload','Thload','Jimma','Tap', ...
         'Svc','Statcom','Busfreq','Pmu','Supply', ...
         'Demand','Syn','Ltc','SAE1','SAE2','SAE3', ...
         'Exc','Tg','Sscl','Cac','Oxl','Pss','Cluster'}
    cloneblock(block{i},sys)
  end
end

lines = find_system(sys,'FindAll','on','type','line');
for i = 1:length(lines)
  points = get_param(lines(i),'Points');
  parent = get_param(lines(i),'Parent');
  delete_line(parent,points(1,:));
  try
    add_line(parent,points);
  catch
    fm_disp(['* * Connection line ',num2str(i),' could not be replaced.'])
  end
end

uiwait(fm_choice('Now please take a moment to doublecheck connections...',2))
fm_disp(' ')
fm_disp(['* * Update of model <',sys,'> completed.'])
