function pmuloc = fm_pmun1
% FM_PMUN1 routine for PMU placement with N-1 contingency
%          criterion in case of device outage
%
% PMU = FM_PMUN1
%     PMU number and position of PMUs
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

fm_var

if isempty(PMU.report)
  fm_pmuloc;
end

nsets = length(PMU.report.Matrix)-2;
nconf = 0;
pmuloc = [];
for i = 1:nsets
  nconf = nconf + size(PMU.report.Matrix{i+2,1},2);
end

if nconf == 1
  pmuloc = PMU.report.Matrix{3,1}(Bus.a,1);
else
  for i = 1:nsets
    pmuloc = [pmuloc; PMU.report.Matrix{i+2,1}(Bus.a,:)];
  end
end

size_pmu = size(pmuloc);

% inizio della routine per determinare
% l'osservabilita' della rete con un
% criterio n-1 sui PMU

gold = DAE.g;
fm_call('series')
roundg = round(abs(DAE.g)/Settings.lftol)*Settings.lftol;
DAE.g = gold;

zeroinj = roundg(Bus.a)+roundg(Bus.v);

for set_i = 1:size_pmu(2)
  fm_disp(['Set of PMU #',num2str(set_i)])
  fm_disp(' ')
  pmu_idx = find(pmuloc(:,set_i));
  pmu_num = length(pmu_idx);

  for pmu_out = 0:pmu_num

    % vettore contenente i bus in cui si collocano i PMU
    pmu_con = [];
    % indice delle correnti misurate:
    % I_idx => [#corrente, #linea, from bus, to bus, sign]
    I_idx = [];

    % conteggio delle connessioni e ordinamento dei nodi
    nodi = [Line.fr; Line.to];
    n_link = zeros(Bus.n,2);
    for i = 1:Bus.n
      a = find(nodi == getidx(Bus,i));
      n_link(i,:) = [getidx(Bus,i), length(a)];
    end
    [y,i] = sort(n_link(:,2));
    n_link = n_link(i,:);
    linee = nodi;
    pseudoi = 0;
    nodi = [];

    pmu_try = pmu_idx;
    if pmu_out, pmu_try(pmu_out) = []; end
    uno = 0; if pmu_out, uno = 1; end
    for pmu_i = 1:pmu_num-uno

      % metti PMU nel nodo non osservabile pi interconnesso
      pmu_con = [pmu_con; getidx(Bus,pmu_try(pmu_i))];
      i_idx = fm_iidx(pmu_con(end),linee);

      if ~isempty(i_idx)
        I_idx = [I_idx; i_idx];
        % nodi osservabili dal PMU
        nodi_oss = [i_idx(:,4);pmu_con(end)];
        nodi = [nodi; nodi_oss];
        linee(i_idx(:,2),[1 2]) = zeros(length(nodi_oss)-1,2);
      end
    end

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
        pi_idx = [api, bpi, cpi];
        linee(pi_idx(:,2),[1 2]) = zeros(length(pi_idx(:,1)),2);
        I_idx = [I_idx; pi_idx];
        pseudoi = pseudoi + length(pi_idx(:,1));
      end
    end

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
          % dopo l'aggiunta di un nuovo nodo misurato bisogna
          % ricontrollare tutti i nodi
          count = 1;

          % ricerca di pseudo-correnti che possono essere misurate
          % con il nodo aggiunto
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
              pi_idx = [api, bpi, cpi];
              linee(pi_idx(:,2),[1 2]) = zeros(length(pi_idx(:,1)),2);
              I_idx = [I_idx; pi_idx];
              pseudoi = pseudoi + length(pi_idx(:,1));
            end
          end

        else
          count = count + 1;
        end
      else
        count = count + 1;
      end
    end

    a = [];
    for i = 1:length(nodi); a = [a; find(n_link(:,1) == nodi(i))]; end
    if ~isempty(a); n_link(a,:) = []; end

    if pmu_out,
      fm_disp(['Without PMU at bus ', ...
            fvar(Bus.names{pmu_idx(pmu_out)},12), ...
            ' Number of not osservable buses ', ...
            num2str(length(n_link(:,1)))])
    else
      fm_disp(['With all PMU''s  Number of not osservable buses ', ...
            num2str(length(n_link(:,1)))])
    end
  end
  fm_disp(' ')
end