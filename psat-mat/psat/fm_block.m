function fm_block
% FM_BLOCK change the mask properties of the current
%          selected Simulink block
%
%see also FM_LIB, FM_SIM, FM_SIMDATA, FM_SIMSETT
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    01-Aug-2003
%Update:    13-Jul-2007
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

fm_var

sys    = get_param(0,'CurrentSystem');
cblock = get_param(sys,'CurrentBlock');
gg     = get_param([sys,'/',cblock],'Selected');
mask   = get_param([sys,'/',cblock],'MaskType');
Object = [sys,'/',cblock];

Values = get_param(Object,'MaskValues');

set_param(Object,'LinkStatus','none')

a = get_param(Object,'MaskEnables');
b = get_param(Object,'MaskPrompts');

switch mask

 case {'Areas', 'Bus', 'Breaker', 'Exc', 'Hvdc', 'Ltc', 'Mn', ...
       'Ind', 'Oxl', 'Pl', 'PQ', 'PQgen', 'Pss', 'Regions', ...
       'Shunt', 'Sssc', 'Svc', 'SW', 'Syn', 'Tcsc', 'Tg'}

  [a,b] = block(eval(mask),Object,Values,a,b);

end

set_param(Object,'MaskEnables',a);
set_param(Object,'MaskPrompts',b);

% set block status
if strcmp(mask,'Breaker'), return, end
if strcmp(mask,'Fault'), return, end
switch Values{end}
 case 'off', set_param(Object,'ForegroundColor','orange');
 otherwise,  set_param(Object,'ForegroundColor','black');
end