function [pmuloc, pmunum] = fm_mintree(zeroinj, hdl_pmu,hdl_nob)
% FM_MINTREE compute minimum spanning tree of the current network
%            (for PMU placement routines)
%
% (...) = FM_MINTREE(...)
%
% This function is generally called by FM_PMULOC
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Bus Line Fig Settings

A = sparse(Bus.n,Bus.n);
pmuloc = sparse(Bus.n,Bus.n);

for i = 1:Bus.n
  nonzero = find(Line.Y(i,:));
  A(i,nonzero) = ones(1,length(nonzero));
end

p = symrcm(A);
r(p) = 1:Bus.n;
A = A(p,p);

spanning = getzeros(Bus);
pmunum = getzeros(Bus);

for i = 1:Bus.n
  spanning = A(i,:);
  pmuloc(i,i) = 1;
  pmunum(i) = 1;
  sumspan = sum(spanning);
  while sumspan < Bus.n
    for j = 1:Bus.n
      B(j) = sum(full(spanning | A(j,:)));
    end
    [value, indice] = max(B);
    spanning = spanning | A(indice,:);
    pmunum(i) = pmunum(i) + 1;
    pmuloc(i,indice) = 1;
    sumspan = sum(spanning);
    if ishandle(Fig.pmu)
      set(hdl_pmu,'String',int2str(pmunum(i)));
      set(hdl_nob,'String',int2str(Bus.n-sumspan));
      drawnow
    end
  end
end

pmuloc = pmuloc(r,r);
pmunum = pmunum(r);