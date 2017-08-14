function check = pst2psat(filename, pathname)
% PST2PSAT convert data files in the Power System Toolbox
%        version 2.0 format in the PSAT format.
%        During the conversion process, approximations
%        and/or guesses may be used.
%
% CHECK = PST2PSAT(FILENAME,PATHNAME)
%       FILENAME name of the file to be converted
%       PATHNAME path of the file to be converted
%
%       CHECK = 1 conversion completed
%       CHECK = 0 problem encountered (no data file created)
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2009 Federico Milano

global Settings

check = 1;
pathname = [pathname,filesep];

fm_disp
fm_disp('Conversion from Power System Toolbox format...');
fm_disp(['Source data file "',pathname,filename,'"'])

% initialization of PST global variables
bus = [];             % load flow data
line = [];
mac_con  = [];        % synchronous machine data
exc_con   = [];       % excitation system data
load_con  = [];       % non-conforming load data
ltc_con = [];
ind_con  = [];        % induction motor data
mld_con  = [];
svc_con = [];         % SVC data
pss_con = [];         % PSS data
tg_con = [];          % turbine-governor data
dcsp_con = [];        % HVDC data
dcl_con = [];
dcc_con = [];
sw_con = [];          % switch data
scr_con = [];
ibus_con = [];
netg_con = [];
stab_con = [];

% load PST data & check for consistency
try,
  eval(filename(1:end-2));
catch,
  check = 0;
  fm_disp('Error encountered while opening PST data file...')
  return,
end
if isempty(bus)
  fm_disp(['Selected file "',filename, ...
           '" does not appear a valid PST data file.'],2);
  check = 0;
  return
end

% some settings
bus(:,3) = pi*bus(:,3)/180;
mvabas = 100;
sizebus = length(bus(:,1));
net_line = line;
sizeline = length(net_line(:,1));
heading = ['File originated from data in PST format: #bus = ', ...
           num2str(sizebus),', #line = ',num2str(sizeline)];

% definition of file name for PSAT data file
newfile = strrep(filename,'.m','_pst.m');
if ~strcmp(newfile(1), 'd'); newfile = ['d_',newfile]; end

% open file for writing
fid = fopen([pathname, newfile], 'wt');
count = fprintf(fid, ['%%  ', heading, '\n\n']);

% Bus data Bus.con
% ---------------------------------------------------------------

fm_disp('bus -> Bus.con')
count = fprintf(fid, 'Bus.con = [ ...\n');
nrow = length(bus(1,:));
bus = [bus,zeros(sizebus,15-nrow)];
idx = find(bus(:,13)==0);
if idx, bus(idx,13) = 1; end
count = fprintf(fid,'%4d %8.4g %8.4g %8.4g;\n',bus([1:end-1],[1,13,2,3])');
count = fprintf(fid,'%4d %8.4g %8.4g %8.4g];\n\n\n',bus(end,[1,13,2,3]));

% Slack bus data SW.con
% ---------------------------------------------------------------

row = find(bus(:,10) == 1);
if ~isempty(row)
  fm_disp('bus -> SW.con')
  count = fprintf(fid, 'SW.con = [ ...\n');
  format = '%4d %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %2u';
  for i = 1:length(row)-1
    k = row(i);
    if ~bus(k,11), bus(k,11) =  99; end
    if ~bus(k,12), bus(k,12) = -99; end
    if ~bus(k,14), bus(k,14) =  1.2; end
    if ~bus(k,15), bus(k,15) =  0.8; end
    data = [bus(k,1),mvabas,bus(k,[13, 2, 3, 11, 12, 14, 15, 4]),1];
    count = fprintf(fid,[format,';\n'],data);
  end
  k = row(end);
  data = [bus(k,1), mvabas, bus(k,[13, 2, 3, 11, 12, 14, 15, 4]),1];
  count = fprintf(fid,[format,']; \n\n\n'],data);
end

% PV bus data PV.con
% ---------------------------------------------------------------------

row = find(bus(:,10) == 2);
if ~isempty(row)
  fm_disp('bus -> PV.con')
  format = '%4d %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %2u';
  count = fprintf(fid, 'PV.con = [ ...\n');
  for i = 1:length(row)-1
    k = row(i);
    if ~bus(k,11), bus(k,11) =  99; end
    if ~bus(k,12), bus(k,12) = -99; end
    if ~bus(k,14), bus(k,14) =  1.2; end
    if ~bus(k,15), bus(k,15) =  0.8; end
    data = [bus(k,1), mvabas, bus(k,[13, 4, 2, 11, 12, 14, 15]),1];
    count = fprintf(fid, [format,';\n'],data);
  end
  k = row(end);
  data = [bus(k,1), mvabas, bus(k,[13, 4, 2, 11, 12, 14, 15]),1];
  count = fprintf(fid, [format,']; \n\n\n'],data);
end

% PQ bus data PQ.con
% ---------------------------------------------------------------------

row = find(bus(:,6) ~= 0 | bus(:,7) ~= 0);
if ~isempty(row)
  fm_disp('bus -> PQ.con')
  count = fprintf(fid, 'PQ.con = [ ...\n');
  format = '%4d %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %2u';
  for i = 1:length(row)-1
    k = row(i);
    if ~bus(k,14), bus(k,14) = 1.2; end
    if ~bus(k,15), bus(k,15) = 0.8; end
    data = [bus(k,1), mvabas, bus(k,[13,6,7,14,15]),0];
    count = fprintf(fid, [format, ';  \n'], data);
  end
  k = row(end);
  data = [bus(k,1), mvabas, bus(k,[13,6,7,14,15]),0];
  count = fprintf(fid, [format,']; \n\n\n'], data);
end

% Shunt bus data Shunt.con
% ---------------------------------------------------------------------

row = find(bus(:,8) ~= 0 | bus(:,9) ~= 0);
if ~isempty(row)
  fm_disp('bus -> Shunt.con')
  count = fprintf(fid, 'Shunt.con	= [ ...\n');
  format = '%4d %8.4g %8.4g %8.4g %8.4g %8.4g';
  for i = 1:length(row)-1
    k = row(i);
    data = [bus(k,1), mvabas, bus(k,13), 60, bus(k,[8,9])];
    count = fprintf(fid, [format,';  \n'], data);
  end
  k = row(end);
  data = [bus(k,1), mvabas, bus(k,13), 60, bus(k,[8,9])];
  count = fprintf(fid, [format, ']; \n\n\n'], data);
end

% Line data Line.con
% --------------------------------------------------------------------

% adjust line matrix dimensions
nrow = length(net_line(1,:));
if nrow < 10, net_line = [net_line,zeros(sizeline,10-nrow)]; end

idx = find(net_line(:,8)==0 & net_line(:,9)==0 & net_line(:,10)==0);
if ~isempty(idx)
  fm_disp('line -> Line.con')
  format = ['%4d %4d %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g ' ...
            '%8.4g %8.4g %8.4g %8.4g %8.4g'];
  count = fprintf(fid, 'Line.con = [ ...\n');
  for i = 1:length(idx)-1
    k = idx(i);
    kV = bus(find(bus(:,1)==net_line(k,1)),13);
    %if net_line(k,6) ~= 0 || net_line(k,7) ~= 0
    kV2 = bus(find(bus(:,1)==net_line(k,2)),13);
    tap = kV/kV2;
    if tap == 1, tap = 0; end
    data = [net_line(k,[1 2]),mvabas,kV,60,0,tap,net_line(k,[3,4,5,6,7]),0];
    %else
    %  data = [net_line(k,[1 2]),mvabas,kV,60,0,0,net_line(k,[3,4,5]),0,0,0];
    %end
    count = fprintf(fid, [format,';\n'],data);
  end
  k = idx(end);
  kV = bus(find(bus(:,1)==net_line(k,1)),13);
  %if net_line(k,6) ~= 0 || net_line(k,7) ~= 0
  kV2 = bus(find(bus(:,1)==net_line(k,2)),13);
  tap = kV/kV2;
  if tap == 1, tap = 0; end
  data = [net_line(k,[1 2]),mvabas,kV,60,0,tap,net_line(k,[3,4,5,6,7]),0];
  %else
  %  data = [net_line(k,[1 2]),mvabas,kV,60,0,0,net_line(k,[3,4,5]),0,0,0];
  %end
  count = fprintf(fid, [format,'];\n\n\n'],data);
end

% Under load transformer data Ltc.con
% ------------------------------------------------------------------------

idx = find(net_line(:,8)~=0 | net_line(:,9)~=0 | net_line(:,10)~=0);
if ~isempty(idx)
  fm_disp('line -> Ltc.con')
  format = ['%4d %4d %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g ' ...
            '%8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %4d'];
  count = fprintf(fid, 'Ltc.con = [ ...\n');
  for i = 1:length(idx)-1
    k = idx(i);
    kV = bus(find(bus(:,1)==net_line(k,1)),13);
    %vref = bus(find(bus(:,1)==net_line(k,2)),2);
    data = [net_line(k,[1,2]),mvabas,kV,60,net_line(k,6),0, ...
            0.1,net_line(k,[8,9,10]),1,net_line(k,[4,3]),0,1];
    count = fprintf(fid, [format, ';\n'],data);
  end
  k = idx(end);
  kV = bus(find(bus(:,1)==net_line(k,1)),13);
  %vref = bus(find(bus(:,1)==net_line(k,2)),2);
  data = [net_line(k,[1,2]),mvabas,kV,60,net_line(k,6),0, ...
          0.1,net_line(k,[8,9,10]),1,net_line(k,[4,3]),0,1];
  count = fprintf(fid, [format, ']; \n\n\n'],data);
end

% Sychronous machine data Syn.con
% --------------------------------------------------------------------

if ~isempty(mac_con)
  fm_disp('mac_con -> Syn.con')
  % adjust mac_con matrix dimension & data
  nrow = length(mac_con(1,:));
  ngen = length(mac_con(:,1));
  if nrow < 23, mac_con = [mac_con,zeros(ngen,23-nrow)]; end
  format = ['%4d %8.4g %8.4g %8.4g %4d %8.4g %8.4g %8.4g %8.4g ' ...
            '%8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g ' ...
            '%8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g'];
  mac_con(find(mac_con(:,22)==0),22) = 1;
  mac_con(find(mac_con(:,23)==0),23) = 1;
  count = fprintf(fid, 'Syn.con = [ ...\n');

  for i = 1:ngen-1
    kV = bus(find(bus(:,1)==mac_con(i,2)),13);
    % choice of machine model
    Td1 = mac_con(i,9);
    Td2 = mac_con(i,10);
    Tq1 = mac_con(i,14);
    Tq2 = mac_con(i,15);
    if Tq2 && Tq1 && Td2, ord = 6;
    elseif Tq2 && Td2,   ord = 5.2;
    elseif Tq1 && Tq2,   ord = 5.1;
    elseif Tq1,         ord = 4;
    elseif Td1,         ord = 3;
    else,               ord = 2;
    end
    data = [mac_con(i,[2,3]),kV,60,ord,mac_con(i,[4:15]),2*mac_con(i,16), ...
            mac_con(i,[17]),0,0,mac_con(i,[22,23]),0];
    count = fprintf(fid, [format, ';\n'],data);
  end
  i = ngen;
  kV = bus(find(bus(:,1)==mac_con(i,2)),13);
  % choice of machine model
  Td1 = mac_con(i,9);
  Td2 = mac_con(i,10);
  Tq1 = mac_con(i,14);
  Tq2 = mac_con(i,15);
  if Tq2 && Tq1 && Td2, ord = 6;
  elseif Tq2 && Td2,   ord = 5.2;
  elseif Tq1 && Tq2,   ord = 5.1;
  elseif Tq1,         ord = 4;
  elseif Td1,         ord = 3;
  else,               ord = 2;
  end
  data = [mac_con(i,[2,3]),kV,60,ord,mac_con(i,[4:15]),2*mac_con(i,16), ...
          mac_con(i,[17]),0,0,mac_con(i,[22,23]),0];
  count = fprintf(fid, [format, '];\n\n\n'],data);
end

% Induction motor data Ind.con
% ------------------------------------------------------------------------

if ~isempty(ind_con) && ~isempty(mld_con) && length(ind_con(:,1))==length(mld_con(:,1))
  fm_disp('ind_con -> Ind.con')
  fm_disp('    Some approximations are used for induction motors:')
  fm_disp('    Check mechanical torque parameters before running the power flow.')
  nmot = length(ind_con(:,1));
  nrow = length(ind_con(1,:));
  if nrow < 15, ind_con = [ind_con,zeros(nmot,15-nrow)]; end
  format = ['%4d %8.4g %8.4g %8.4g %4d %4d %8.4g %8.4g %8.4g ' ...
            '%8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g'];
  ind_con = ind_con(mld_con(:,1),:);
  count = fprintf(fid, 'Ind.con = [ ...\n');
  for i = 1:nmot-1
    kV = bus(find(bus(:,1)==ind_con(i,2)),13);
    r2 = ind_con(i,10);
    x2 = ind_con(i,11);
    r1 = ind_con(i,4);
    if r2 || x2, ord = 5;
    elseif r1,  ord = 3;
    else,       ord = 1;
    end
    %sup = ind_con(i,15);
    %if sup, sup = 1; end
    sup = 1;
    data = [ind_con(i,[2,3]),kV,60,ord,sup,ind_con(i,[4,5,7,8,10,11,6,9]), ...
            mld_con(i,3),-mld_con(i,3),mld_con(i,5)];
    count = fprintf(fid,[format, ';\n'],data);
  end
  i = nmot;
  kV = bus(find(bus(:,1)==ind_con(i,2)),13);
  r2 = ind_con(i,10);
  x2 = ind_con(i,11);
  r1 = ind_con(i,4);
  if r2 || x2, ord = 5;
  elseif r1,  ord = 3;
  else,       ord = 1;
  end
  sup = ind_con(i,15);
  if sup, sup = 1; end
  data = [ind_con(i,[2,3]),kV,60,ord,sup,ind_con(i,[4,5,7,8,10,11,6,9]), ...
          mld_con(i,3),-mld_con(i,3),mld_con(i,5)];
  count = fprintf(fid,[format, '];\n\n\n'],data);
end

% Polinomial load data Pl.con
% ---------------------------------------------------------------------

if ~isempty(load_con)
  fm_disp('load_con -> Pl.con')
  format = ['%4d %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g ' ...
  '%8.4g %2d'];
  P = load_con(:,2);
  Q = load_con(:,3);
  Ip = load_con(:,4);
  Iq = load_con(:,5);
  idx = find(P+Q+Ip+Iq == 0);
  if ~isempty(idx)
    load_con(idx,:) = [];
  end
  npol = length(load_con(:,1));
  if npol, count = fprintf(fid, 'Pl.con = [ ...\n'); end
  for i = 1:npol-1
    kV = bus(find(bus(:,1)==load_con(i,1)),13);
    P = 100*load_con(i,2);
    Q = 100*load_con(i,3);
    Ip = 100*load_con(i,4);
    Iq = 100*load_con(i,5);
    data = [load_con(i,1),mvabas,kV,60,0,Ip,P,0,Iq,Q,1];
    count = fprintf(fid, [format, ';\n'],data);
  end
  if npol
    kV = bus(find(bus(:,1)==load_con(npol,1)),13);
    P = 100*load_con(npol,2);
    Q = 100*load_con(npol,3);
    Ip = 100*load_con(npol,4);
    Iq = 100*load_con(npol,5);
    data = [load_con(npol,1),mvabas,kV,60,0,Ip,P,0,Iq,Q,1];
    count = fprintf(fid, [format, '];\n\n\n'],data);
  end
end

% Automatic Voltage Regulator data Exc.con
% -------------------------------------------------------------------

if ~isempty(exc_con)
  fm_disp('exc_con -> Exc.con')
  idx = find(exc_con(:,1) < 3);
  nexc = length(idx);
  if nexc < length(exc_con(:,1))
    fm_disp(['Model IEEE Type ST3 Exciters are approximated with AVR ' ...
             'type III.'])
  end
  if nexc ~= 0
    fm_disp('Model IEEE Type DC1 and DC2 Exciters are approximated with AVR type II.')
  end
  format = '%4d %4d %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g';
  count = fprintf(fid, 'Exc.con = [ ...\n');
  for i = 1:length(exc_con(:,1))-1
    genn = find(mac_con(:,1) == exc_con(i,2));
    if exc_con(i,1) < 3
      Tf = exc_con(i,17);
      Te = exc_con(i,11);
      if ~Te && ~Tf
        data = [genn,3,exc_con(i,[8,9,4,5,7]),0,0,0,exc_con(i,3),0,0];
      else
        data = [genn,2,exc_con(i,[8,9,4,5,16,17]),0, ...
                exc_con(i,[11,3]),0.0006,0.9];
      end
    else
      data = [genn,3,exc_con(i,[8,9]),exc_con(i,[4,6,7]),0,0,0,0,0,0];
    end
    if data(3) < 2.5
      fm_disp('Found Vr_max <  2.5 p.u. -> reset to  2.5 p.u.')
      data(3) = 2.5;
    end
    if data(4) > -2.5
      fm_disp('Found Vr_min > -2.5 p.u. -> reset to -2.5 p.u.')
      data(4) = -2.5;
    end
    count = fprintf(fid, [format, ';\n'],data);
  end
  i = length(exc_con(:,1));
  genn = find(mac_con(:,1) == exc_con(i,2));
  if exc_con(i,1) < 3
    Tf = exc_con(i,17);
    Te = exc_con(i,11);
    if ~Te && ~Tf
      data = [genn,3,exc_con(i,[8,9,4,5,7]),0,0,0,exc_con(i,3),0,0];
    else
      data = [genn,2,exc_con(i,[8,9,4,5,16,17]),0, ...
              exc_con(i,[11,3]),0.0006,0.9];
    end
  else
    data = [genn,3,exc_con(i,[8,9]),exc_con(i,[4,6,7]),0,0,0,0,0,0];
  end
  if data(3) < 2.5
    fm_disp('Found Vr_max <  2.5 p.u. -> reset to  2.5 p.u.')
    data(3) = 2.5;
  end
  if data(4) > -2.5
    fm_disp('Found Vr_min > -2.5 p.u. -> reset to -2.5 p.u.')
    data(4) = -2.5;
  end
  count = fprintf(fid, [format, '];\n\n\n'],data);
end

% Turbine Governor data Tg.con
% ---------------------------------------------------------------------

if ~isempty(tg_con)
  fm_disp('tg_con -> Tg.con')
  ntg = length(tg_con(:,1));
  tg_con(:,4) = 1./tg_con(:,4);
  format = ['%4d %4d %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g'];
  count = fprintf(fid, 'Tg.con = [ ...\n');
  for i = 1:ntg-1
    gen = find(mac_con(:,1) == tg_con(i,2));
    data = [gen,1,tg_con(i,[3,4,5]),0,tg_con(i,[6,7,8,9,10])];
    count = fprintf(fid, [format, ';\n'],data);
  end
  i = ntg;
  gen = find(mac_con(:,1) == tg_con(i,2));
  data = [gen,1,tg_con(i,[3,4,5]),0,tg_con(i,[6,7,8,9,10])];
  count = fprintf(fid, [format, '];\n\n\n'],data);
end

% Power System Stabilizer data Pss.con
% --------------------------------------------------------------------

if ~isempty(pss_con)
  fm_disp('pss_con -> Pss.con')
  npss = length(pss_con(:,1));
  format = ['%4d %4d %4d %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g ', ...
            '%8.4g ... \n %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %4d'];
  count = fprintf(fid, 'Pss.con = [ ...\n');
  for i = 1:npss-1
    exc = find(exc_con(:,2) == pss_con(i,2));
    Kw = pss_con(i,3)/pss_con(i,4);
    data = [exc,2,pss_con(i,[1,9,10]),Kw, ...
            pss_con(i,[4,5,6,7,8]),0,0,0,0,0,0,0,0,0,0,0];
    count = fprintf(fid, [format, ';\n'],data);
  end
  i = npss;
  exc = find(exc_con(:,2) == pss_con(i,2));
  Kw = pss_con(i,3)/pss_con(i,4);
  data = [exc,2,pss_con(i,[1,9,10]),Kw, ...
          pss_con(i,[4,5,6,7,8]),0,0,0,0,0,0,0,0,0,0,0];
  count = fprintf(fid, [format, '];\n\n\n'],data);
end

% Static Var Compensator data Svc.con
% ---------------------------------------------------------------------

if ~isempty(svc_con)
  fm_disp('svc_con -> Svc.con')
  nsvc = length(svc_con(:,1));
  format = ['%4d %8.4g %8.4g %8.4g %4d %8.4g %8.4g %8.4g %8.4g ', ...
            '%8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g'];
  count = fprintf(fid, 'Svc.con = [ ...\n');
  for i = 1:nsvc-1
    kV = bus(find(bus(:,1)==svc_con(i,2)),13);
    Vref = bus(find(bus(:,1)==svc_con(i,2)),2);
    data = [svc_con(i,[2,3]),kV,60,1,svc_con(i,[7,6]), ...
            Vref,svc_con(i,[4,5]),0,0,0,0,0,0];
    count = fprintf(fid, [format, '; \n'],data);
  end
  i = nsvc;
  kV = bus(find(bus(:,1)==svc_con(i,2)),13);
  Vref = bus(find(bus(:,1)==svc_con(i,2)),2);
  data = [svc_con(i,[2,3]),kV,60,1,svc_con(i,[7,6]), ...
          Vref,svc_con(i,[4,5]),0,0,0,0,0,0];
  count = fprintf(fid, [format, ']; \n\n\n'],data);
end

% Switching operation data Breaker.con & Fault.con
% -----------------------------------------------------------------------

if ~isempty(sw_con)
  switch sw_con(2,6)
   case 5
    fm_disp('For describing a loss of load use a perturbation file.')
   case 4
    fm_disp('sw_con -> Breaker.con')
    format = '%4d %4d %4d %8.4g %8.4g';
    linen = find(net_line(:,1) == sw_con(2,2) & ...
                 net_line(:,2) == sw_con(2,3));
    if isempty(linen)
      linen = find(net_line(:,2) == sw_con(2,2) & ...
                   net_line(:,1) == sw_con(2,3));
    end
    if isempty(linen),
      fm_disp('No line was found with the terminals as specified in sw_con')
    else
      kV = bus(find(bus(:,1)==sw_con(2,2)),13);
      data = [linen, sw_con(2,2),1,sw_con(2,1),sw_con(5,1)+1];
      count = fprintf(fid, ['Breaker.con = [',format,'];\n\n\n'],data);
    end
   case 6
    fm_disp('No fault operations.')
   otherwise
    fm_disp('sw_con -> Fault.con')
    switch sw_con(2,6)
     case 1
      fm_disp('Line-to-ground fault is approximated as a three phase fault.')
     case 2
      fm_disp('Line-to-line-to-ground fault is approximated as a three phase fault.')
     case 3
      fm_disp('Line-to-line fault is approximated as a three phase fault.'),
    end
    format = '%4d %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g';
    kV = bus(find(bus(:,1)==sw_con(2,2)),13);
    data = [sw_con(2,2),mvabas,kV,60,sw_con(2,1),sw_con(4,1),0, 0];
    count = fprintf(fid, ['Fault.con = [',format,'];\n\n\n'],data);
  end

  fm_disp('sw_con -> Settings')
  count = fprintf(fid, ['Settings.t0 = ',num2str(sw_con(1,1)),';\n']);
  count = fprintf(fid, ['Settings.tf = ',num2str(sw_con(5,1)),';\n']);

end

% end of operations
count = fclose(fid);
fm_disp(['Conversion into data file "',pathname,newfile,'" completed.'])
if Settings.beep, beep, end
