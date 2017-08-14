function [pmu_test, pmu_test2, I_idx, pseudoi, index_pmu, pmunum] = fm_spantree(zeroinj, pmuloc, pmunum, hdl_pmu, hdl_nob)
% FM_SPANTREE routine for determining the spanning tree.  It is
%             used for placing PMUs.
%
% (...) = FM_SPANTREE(...)
%
% This function is called by FM_PMULOC
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Bus Line Fig

% costruzione della matrice di adiacenza di rete
A = zeros(Bus.n,Bus.n);
for i = 1:Bus.n
  nonzero = find(Line.Y(i,:));
  A(i,nonzero) = ones(1,length(nonzero));
end

% spostamento dei PMU dai nodi in antenna sul nodo adiacente collegato
for i = 1:length(pmunum)
  idx = find(pmuloc(i,:));
  for j = 1:length(idx)
    if sum(A(idx(j),:)) == 2 && ~zeroinj(idx(j)) == 0
      c = zeros(1,Bus.n);
      c(1,idx(j)) = 1;
      b = A(idx(j),:) - c;
      pmuloc(i,idx(j)) = 0;
      pmuloc(i,find(b)) = 1;
    end
  end
end

% determinazione delle misure e delle pseudo misure di corrente
[sortpmu, pmuidx] = sort(pmunum);
pmuloc = pmuloc(pmuidx,:);
pmu_test2 = cell(length(pmunum),1);

for i = 1:length(pmunum)

  pmu_test_new = getidx(Bus,find(pmuloc(i,:)));
  ntest = length(pmu_test_new);
  if ishandle(Fig.pmu)
    set(hdl_pmu,'String',int2str(ntest));
    drawnow
  end
  linee = [Line.fr, Line.to];

  I_idx = [];
  nodi = [];
  pseudoi = 0;

  for ijk = 1:ntest
    i_idx = fm_iidx(pmu_test_new(ijk),linee);
    I_idx = [I_idx; i_idx];
    nodi_oss = [i_idx(:,4);pmu_test_new(ijk)];
    nodi = [nodi; nodi_oss];
    if ishandle(Fig.pmu)
      set(hdl_nob,'String',int2str(length(nodi)));
      drawnow
    end
  end

  nodi = sort(nodi);
  num_nodi = length(nodi);
  nodi_el = [];
  for jjj = 1:num_nodi
    nodi_el = [nodi_el; jjj+find(nodi([jjj+1:num_nodi]) == nodi(jjj))];
  end
  nodi(nodi_el) = [];

  % determinazione delle pseudo-correnti nelle linee
  % ai cui estremi sono note le tensioni
  pi_idx = [];
  for ii = 1:length(nodi)
    I_idx_from = find(linee(:,1) == nodi(ii));
    I_idx_to = [];
    for jj = 1:length(nodi)
      ifrom = find(linee(I_idx_from,2) == nodi(jj));
      I_idx_to = [I_idx_to; I_idx_from(ifrom)];
    end
    if ~isempty(I_idx_to);
      n_current = length(I_idx_to);
      api = [[1:n_current]', I_idx_to];
      bpi = linee(I_idx_to,[1 2]);
      cpi = ones(length(I_idx_to),1);
      pi_idx = [pi_idx; [api, bpi, cpi]];
    end
  end

  if ~isempty(pi_idx)
    linee(pi_idx(:,2),[1 2]) = zeros(length(pi_idx(:,1)),2);
    I_idx = [I_idx; pi_idx];
    pseudoi = pseudoi + length(pi_idx(:,1));
  end

  % determinazione delle pseudo-correnti  determinate
  % con la legge di Kirchhoff per le correnti
  % ed eliminazione dei nodi di cui si pu determinare
  % la tensione con la legge di Ohm
  count = 1;
  while count < length(nodi)
    if zeroinj(Bus.int(nodi(count))) == 0
      I_idx_from = find(linee(:,1) == nodi(count));
      I_idx_to = find(linee(:,2) == nodi(count));
      ncfrom = length(I_idx_from);
      ncto = length(I_idx_to);
      nc = ncfrom + ncto;
      if nc == 1
        if ncfrom == 1
          ki_idx = [1, I_idx_from, linee(I_idx_from,[1 2]), 1];
        else
          ki_idx = [1, I_idx_to, linee(I_idx_to,[2 1]), -1];
        end
        linee(ki_idx(2),[1 2]) = zeros(length(ki_idx(1)),2);
        I_idx = [I_idx; ki_idx];
        pseudoi = pseudoi + length(ki_idx(1));
        nodi_oss = [nodi_oss; ki_idx(4)];
        nodi = [ki_idx(4); nodi];
        if ishandle(Fig.pmu)
          set(hdl_nob,'String',int2str(length(nodi)));
        end
        drawnow
        count = 1;
      else
        count = count + 1;
      end
    else
      count = count + 1;
    end
  end

  pmu_test2{i,1} = pmu_test_new;
  I_idx_test{i,1} = I_idx;
  pseudi_test{i,1} = pseudoi;

end

pmu_status = zeros(length(pmu_test2),1);
min_pmu = Bus.n;
for i = 1:length(pmu_test2)
  if length(pmu_test2{i,1}) == 1
    pmu_status(i) = 1;
    min_pmu = 1;
  end
end

while ~all(pmu_status)
  a = find(~pmu_status);
  if ishandle(Fig.pmu)
    set(hdl_pmu,'String',int2str(length(pmu_test2{a(1)})));
    drawnow
  end

  [pmu_test2, I_idx_test, pseudi_test ,pmu_status, min_pmu] = ...
      fm_pmutry(pmu_test2,I_idx_test, pseudi_test,pmu_status, ...
                a(1),hdl_nob,hdl_pmu, min_pmu, zeroinj);

  pmuloc = sparse(length(pmu_test2),Bus.n);
  pmunum = zeros(1,length(pmu_test2));
  for i = 1:length(pmu_test2)
    pmuloc(i,Bus.int(pmu_test2{i})) = ones(1,length(pmu_test2{i}));
    pmunum(i) = sum(pmuloc(i,:));
  end

  % eliminazione delle configuazioni rindondanti
  pos = 1;
  while pos < length(pmunum)
    idx = [];
    idxo = 1:pos;
    for i = pos+1:length(pmunum)
      if (pmuloc(pos,:) && pmuloc(i,:)) == pmuloc(pos,:)
        idx = [idx, i];
      else
        idxo = [idxo, i];
      end
    end
    pmunum(idx) = [];
    pmuloc(idx,:) = [];
    pmu_test2(idx) = [];
    I_idx_test(idx) = [];
    pseudi_test(idx) = [];
    pmu_status(idx) = [];
    pos = pos + 1;
  end
end
numpmu = Bus.n;
numpmuold = Bus.n;
index_pmu = [];
for i = 1:length(pmu_test2)
  numpmu = min(numpmu, length(pmu_test2{i,1}));
end
for i = 1:length(pmu_test2)
  if numpmu == length(pmu_test2{i,1})
    index_pmu = [index_pmu; i];
  end
end
pmu_test = pmu_test2(index_pmu);
I_idx = I_idx_test(index_pmu);
pseudoi = pseudi_test(index_pmu);
if ishandle(Fig.pmu)
  set(hdl_pmu,'String',int2str(numpmu));
  set(hdl_nob,'String',int2str(0));
  drawnow
end