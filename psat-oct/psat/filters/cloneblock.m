function cloneblock(varargin)
% CLONEBLOCK update the ancestor block of a PSAT-Simulink model
%
% CLONEBLOCK(BLOCK,SYS)
%            BLOCK handle to the block to be updated
%            SYS   handle to the system to which the block belongs
%
%see also FM_LIB
%
%Author:    Federico Milano
%Date:      04-Jun-2008
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2009 Federico Milano

switch nargin
 case 0
  block = gcb;
  sys = gcs;
 case 1
  block = varargin{1};
  sys = gcs;
 otherwise
  block = varargin{1};
  sys = varargin{2};
end

name = get_param(block,'Name');
clone = find_system(sys,'Name',name);
type = get_param(block,'MaskType');
pos = get_param(block,'Position');
orient = get_param(block,'Orientation');
bgcolor = get_param(block,'BackgroundColor');
fontname = get_param(block,'FontName');
fontsize = get_param(block,'FontSize');
maskvalue = get_param(block,'MaskValueString');
nameplace = get_param(block,'NamePlacement');

switch type
 case 'Bus'
  template = 'Bus1';
 case 'Link'
  template = 'Link1';
 case 'SW'
  template = 'Slack';
 case 'Mot'
  template = 'Ind';
 case 'Shunt'
  a = get_param(block,'MaskPrompts');
  if strmatch('Conductance',a{2})
    template = 'Shunt';
  elseif strmatch('Susceptance',a{2})
    template = 'Shunt1';
  end
 case 'PV'
  if length(get_param(block,'MaskVarAliases')) == 7
    template = 'PV';
  else
    template = 'SC';
  end
 case 'Line'
  if length(get_param(block,'MaskVarAliases')) == 7
    a = get_param(block,'MaskDescription');
    if ~isempty(strfind(a,'shifter'))
      template = 'Transf3';
    elseif ~isempty(strfind(a,'cable'))
      template = 'Line1';
    elseif ~isempty(strfind(a,'tap ratio'))
      template = 'Transf2';
    else
      template = 'Line';
    end
  elseif length(get_param(block,'MaskVarAliases')) == 8
    template = 'Transf4';
  elseif length(get_param(block,'MaskVarAliases')) == 6
    a = get_param(block,'MaskDescription');
    if ~isempty(strfind(a,'auto'))
      template = 'Auto';
    else
      template = 'Transf1';
    end
  end
 otherwise
  template = type;
end

updatesyn = 0;
updatesup = 0;
updatedem = 0;
updatebus = 0;
if strcmp(type,'Syn')
  values = get_param(block,'MaskValues');
  if length(values) == 12
    in = get_param(block,'in');
    updatesyn = 1;
  end
elseif strcmp(type,'Supply')
  values = get_param(block,'MaskValues');
  if length(values) == 8
    in = get_param(block,'in');
    updatesup = 1;
  end
elseif strcmp(type,'Demand')
  values = get_param(block,'MaskValues');
  if length(values) == 9
    out = get_param(block,'out');
    updatedem = 1;
  end
elseif strcmp(type,'Bus')
  values = get_param(block,'MaskValues');
  if length(values) == 4, updatebus = 1; end
end

ancestor = find_system('fm_lib','LookUnderMasks','functional','Name',template);

if isempty(clone)
  fm_disp('* * Troubles in defining destination block')
elseif isempty(ancestor)
  fm_disp('* * Troubles in finding library source (broken library link)')
else
  if iscell(clone), clone = clone{1}; end
  if iscell(ancestor), ancestor = ancestor{1}; end
  try
    a_old = get_param(block,'MaskPrompts');
    delete_block(block)

    newblock = add_block(ancestor,clone);

    set_param(newblock, ...
              'Name',name, ...
              'Position',pos, ...
              'Orientation',orient, ...
              'BackgroundColor',bgcolor, ...
              'FontName',fontname, ...
              'FontSize',fontsize, ...
              'NamePlacement',nameplace, ...
              'MaskValueString',maskvalue)

    if updatesup
      set_param(newblock,'p15q','1')
      set_param(newblock,'p16_17q','[0 0]')
      set_param(newblock,'p18_19q','[0 0]')
      set_param(newblock,'in',in)
    end
    if updatedem
      set_param(newblock,'p16_17q','[0 0]')
      set_param(newblock,'out',out)
    end
    if updatesyn
      set_param(newblock,'p25_26q','[0 0]')
      set_param(newblock,'in',in)
    end
    if updatebus
      set_param(newblock,'p5q','1')
      set_param(newblock,'p6q','1')
    end

    a = get_param(newblock,'MaskPrompts');
    if strcmp('Connected',a{end}) && ...
          ~strcmp('Connected',a_old{end})
      b = get_param(newblock,'MaskNames');
      set_param(newblock,b{end},'on')
    end

  catch
    lasterr
    fm_disp(['* * Troubles in replacing block <', ...
             clone,'> with <',ancestor,'>'])
  end
end