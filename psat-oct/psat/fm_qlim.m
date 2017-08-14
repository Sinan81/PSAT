function  [Qx,Qn] = fm_qlim(flag)
% FM_QLIM determine max and min bus reactive powers
%
% [QMAX,QMIN] = FM_QLIM(FLAG)
%       FLAG -> 'all' full bus vector
%               'gen' vector of generator buses
%       QMAX -> vector of max bus reactive powers (p.u.)
%       QMIN -> vector of min bus reactive powers (p.u.)
%
%Author:    Federico Milano
%Date:      27-Dic-2005
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
%Copyright (C) 2002-2016 Federico Milano

global Bus SW PV Supply Settings

switch flag

 case 'all'

  Qn = getzeros_bus(Bus);
  Qx = getzeros_bus(Bus);

  [q,idx] = qmin_pv(PV);
  if ~isempty(idx), Qn(idx) = q; end
  [q,idx] = qmax_pv(PV);
  if ~isempty(idx), Qx(idx) = q; end
  [q,idx] = qmin_sw(SW);
  if ~isempty(idx), Qn(idx) = q; end
  [q,idx] = qmax_sw(SW);
  if ~isempty(idx), Qx(idx) = q; end

 case 'gen'

  [qmin_pv,idx_pv] = qmin_pv(PV);
  [qmax_pv,idx_pv] = qmax_pv(PV);
  [qmin_sw,idx_sw] = qmin_sw(SW);
  [qmax_sw,idx_sw] = qmax_sw(SW);

  busg = [idx_sw; idx_pv];
  Qmin = [qmin_sw; qmin_pv];
  Qmax = [qmax_sw; qmax_pv];
  [Qx,Qn] = suqlim_supply(Supply,Qmax,Qmin,busg);
  if Settings.octave
    busS = setdiff(busg,Supply.bus);
    [dummy,idxS] = ismember(busS,Supply.bus);
  else
    [busS,idxS] = setdiff(busg,Supply.bus);
  end
  if ~isempty(busS)
    Qn = [Qn; Qmin(idxS)];
    Qx = [Qx; Qmax(idxS)];
  end

end