function [bus_pmu, bus2] = fm_pmurec(bus1,bus2,bus0)
% FM_PMUREC routine for PMU placement
%
% (...) = FM_PMUREC(...)
%
% This routine is called by FM_PMULOC
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Bus Line

b = busidx(Line,bus1);
if length(b) == 1
  bus_pmu = b;
  bus2(Bus.int(b)) = 1;
  return
end

b1 = find(~bus2(Bus.int(b)));
if isempty(b1)
  bus_pmu = [];
  return
else
  b = sort(b(b1));
end

bus2(Bus.int(b)) = ones(length(b),1);

bb = [];

for k = 1:length(b)
  abb = busidx(Line,b(k));
  abb = abb(find(~bus2(Bus.int(abb))));
  bb = [bb; abb];
end

if isempty(bb); bus_pmu = []; return; end

bb = sort(bb);
num_bus = length(bb);
nodi_el = [];
for jjj = 1:num_bus-1
  nodi_el = [nodi_el; jjj + find(bb([jjj+1:num_bus]) == bb(jjj))];
end
bb(nodi_el) = [];
bb = bb(find(~bus2(Bus.int(bb))));
bus2(Bus.int(bb)) = ones(length(bb),1);

bus_pmu = sort(bb);