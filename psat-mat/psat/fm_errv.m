function fm_errv(Vold,msg,busidx)
% FM_ERRV compute absolute voltage rate errors
%
% FM_ERRV(VRATE,MSG,BUSIDX)
%       VRATE  -> component voltage rate
%       MSG    -> string for displaying message
%       BUSIDX -> component indexes
%
%Author:    Federico Milano
%Date:      25-Dic-2005
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Bus

Vbus = getkv(Bus,busidx,1);
Verr = abs((Vbus-Vold)./Vbus);
idx = find(Verr > 0.1);
for iii = 1:length(idx)
  kkk = idx(iii);
  fm_disp(['Voltage rate of ',msg,' #', num2str(kkk), ...
           ' at Bus ',Bus.names{busidx(kkk)}, ...
           ' differs more than 10% from Bus voltage rate'],2)
end