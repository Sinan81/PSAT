function [Vest, angest, rangoH] = fm_lssest(pmu_con, I_idx, cal_inv)
% FM_LSSEST linear static state estimation using current PMU placement
%
% (...) = FM_LSSEST(...)
%
%This function is generally called by FM_PMULOC
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Line Bus jay DAE Settings

% complex voltages
VV = DAE.y(Bus.v).*exp(jay*DAE.y(Bus.a));

% measured and non-measured voltage indexes
bus_mis = Bus.int(pmu_con);
n_mis = length(pmu_con);
bus_cal = Bus.a;
cal_con = getidx(Bus,0);
a = [];
for i = 1:length(pmu_con)
  a = [a; find(bus_cal == bus_mis(i))];
end
if ~isempty(a)
  bus_cal(a) = [];
  cal_con(a) = [];
end
n_cal = length(bus_cal);

% build Y_BB: diagonal matrix of line admittances (n x n)
Y_BB = diagy(Line);

% measured current indexes:
% I_idx => [#current, #line, from bus, to bus, sign]
n_imis = length(I_idx(:,1));
[I_mis,dummy] = flows(Line,'current',I_idx(:,2));

% build M_IB
M_IB = sparse(I_idx(:,1),I_idx(:,2),I_idx(:,5),n_imis,Line.n);

% build A_MB
V_idx = [];
for i = 1:n_mis
  V_idx_fr = find(Line.fr == pmu_con(i));
  V_idx_to = find(Line.to == pmu_con(i));
  avm = [V_idx_fr; V_idx_to];
  bvm = [ones(length(V_idx_fr),1); -ones(length(V_idx_to),1)];
  cvm = i*ones(length(avm),1);
  V_idx = [V_idx; [avm, bvm, cvm]];
end
A_MB = sparse(V_idx(:,3),V_idx(:,1),V_idx(:,2),n_mis,Line.n);

% build A_CB
V_idx = [];
for i = 1:n_cal
  V_idx_fr = find(Line.fr == cal_con(i));
  V_idx_to = find(Line.to == cal_con(i));
  avc = [V_idx_fr; V_idx_to];
  bvc = [ones(length(V_idx_fr),1); -ones(length(V_idx_to),1)];
  cvc = i*ones(length(avc),1);
  V_idx = [V_idx; [avc, bvc, cvc]];
end
A_CB = sparse(V_idx(:,3),V_idx(:,1),V_idx(:,2),n_cal,Line.n);

% build identity matrix of measured bus
% and zero matrix (n_mis x n_cal)
Id = speye(n_mis);
Nihil = sparse(n_mis,n_cal);

% build H
H = [Id, Nihil; M_IB*Y_BB*[A_MB', A_CB']];

if cal_inv
  % state estimation (no measurement errors)
  VVest = (H'*H)\H'*[VV(bus_mis); I_mis];
  Vest = getzeros(Bus);
  angest = getzeros(Bus);
  Vest([bus_mis; bus_cal]) = abs(VVest);
  angest([bus_mis; bus_cal]) = angle(VVest);
  rangoH = 0;
else
  rangoH = rank(full(H));
  Vest = 0;
  angest = 0;
end