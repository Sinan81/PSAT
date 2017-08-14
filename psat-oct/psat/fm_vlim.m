function  [Vx,Vn] = fm_vlim(maxV,minV)
% FM_VLIM determines max and min bus voltages
%
% [VMAX,VMIN] = FM_VLIM(MAXV,MINV)
%       MAXV -> default max voltage
%       MINV -> default min voltage
%       VMAX -> vector of max bus voltages
%       VMIN -> vector of min bus voltages
%
%Author:    Federico Milano
%Date:      26-Dic-2005
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
%Copyright (C) 2002-2016 Federico Milano

global Bus SW PV PQ

Vn = getzeros_bus(Bus);
Vx = getzeros_bus(Bus);

if PQ.n
  Vn(PQ.bus) = vmin_pq(PQ);
  Vx(PQ.bus) = vmax_pq(PQ);
end

if PV.n
  Vn(PV.bus) = vmin_pv(PV);
  Vx(PV.bus) = vmax_pv(PV);
end

if SW.n
  Vn(SW.bus) = vmin_sw(SW);
  Vx(SW.bus) = vmax_sw(SW);
end

Vn(find(Vn == 0)) = minV;
Vx(find(Vx == 0)) = maxV;