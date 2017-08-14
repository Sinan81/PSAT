function [pmu_test2, I_idx_test, pseudi_test ,pmu_status, min_pmu] = fm_pmutry(pmu_test2,I_idx_test, pseudi_test ,pmu_status,sel_pmu,hdl_nob,hdl_pmu, min_pmu, zeroinj)
% FM_PMUTRY routine for PMU placement
%
% (...) = FM_PMUTRY(...)
%
%This routine is generally called by FM_PMULOC
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

pmu_test = pmu_test2{sel_pmu};
test_len = length(pmu_test);
pmu_test3 = [];
I_idx_test3 = [];
pseudi_test3 = [];
test3_idx = 0;
idx4 = [];

for i = 1:test_len

  vaipure = 1;
  connes = find(Line.Y(Bus.int(pmu_test(i)),:));
  for j = 1:length(connes)
    if length(find(Line.Y(connes(j),:))) == 2 && ...
          zeroinj(Bus.int(pmu_test(i))) > 0
      vaipure = 0;
      break
    end
  end

  if vaipure
    pmu_test_new = pmu_test([1:i-1, i+1:test_len]);
    if ishandle(Fig.pmu)
      set(hdl_pmu,'String',int2str(test_len));
      drawnow
    end
    linee = [Line.fr, Line.to];
    I_idx = [];
    nodi = [];
    pseudoi = 0;

    for ijk = 1:test_len-1
      i_idx = fm_iidx(pmu_test_new(ijk),linee);
      I_idx = [I_idx; i_idx];
      nodi_oss = [i_idx(:,4);pmu_test_new(ijk)];
      nodi = [nodi; nodi_oss];
      if ishandle(Fig.pmu)
        set(hdl_nob,'String',int2str(length(nodi)));
        drawnow
      end
    end

    linee(I_idx(:,2),[1 2]) = zeros(length(I_idx(:,1)),2);

    % determinazione delle pseudo-correnti  determinate con
    % la legge di Kirchhoff per le correnti
    % ed eliminazione dei nodi di cui si pu determinare la
    % tensione con la legge di Ohm
    % determinazione delle pseudo-correnti nelle linee ai cui
    % estremi sono note le tensioni
    for ii = 1:length(nodi)
      I_idx_from = find(linee(:,1) == nodi(ii));
      if ~isempty(I_idx_from)
        I_idx_to = [];
        for jj = 1:length(I_idx_from)
          if ~isempty(find(nodi == linee(I_idx_from(jj),2)))
            I_idx_to = [I_idx_to; I_idx_from(jj)];
          end
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
          if ishandle(Fig.pmu)
            set(hdl_nob,'String',int2str(length(nodi)));
            drawnow
          end

          % dopo l'aggiunta di un nuovo nodo misurato bisogna
          % ricontrollare tutti i nodi
          count = 1;

          % ricerca di pseudo-correnti che possono essere misurate
          % con il nodo aggiunto
          for ii = 1:length(nodi)
            I_idx_from = find(linee(:,1) == nodi(ii));
            if ~isempty(I_idx_from)
              I_idx_to = [];
              for jj = 1:length(I_idx_from)
                if ~isempty(find(nodi == linee(I_idx_from(jj),2)))
                  I_idx_to = [I_idx_to; I_idx_from(jj)];
                end
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
          end

        else
          count = count + 1;
        end
      else
        count = count + 1;
      end
    end

    nodi_ord = sort(nodi);
    num_nodi = length(nodi);
    nodi_el = [];
    for jjj = 1:num_nodi
      nodi_el = [nodi_el; jjj+find(nodi_ord([jjj+1:num_nodi]) == ...
                                   nodi_ord(jjj))];
    end
    nodi_ord(nodi_el) = [];
    if ishandle(Fig.pmu)
      set(hdl_nob,'String',int2str(Bus.n-length(nodi_ord)));
      drawnow
    end

    if length(nodi_ord) == Bus.n
      idx4 = [idx4; i];
      test3_idx = test3_idx + 1;
      pmu_test3{test3_idx,1} = pmu_test_new;
      I_idx_test3{test3_idx,1} = I_idx;
      pseudi_test3{test3_idx,1} = pseudoi;
      if ishandle(Fig.pmu)
        set(hdl_pmu,'String',int2str(test_len-1));
        set(hdl_nob,'String',int2str(Bus.n-length(nodi_ord)));
        drawnow
      end
      min_pmu = min(min_pmu,test_len-1);
    end
  end
end

if test3_idx > 0 && (test_len-length(pmu_test3)) < min_pmu

  pmu_test2(sel_pmu) = [];
  pmu_status(sel_pmu) = [];
  pmu_test2 = [pmu_test3; pmu_test2];
  I_idx_test = [I_idx_test3; I_idx_test];
  pseudi_test = [pseudi_test3; pseudi_test];
  pmu_status = [zeros(length(pmu_test3),1); pmu_status];

  if ishandle(Fig.pmu)
    set(hdl_pmu,'String',int2str(test_len-1));
    drawnow
  end

elseif test3_idx > 0 && (test_len-length(pmu_test3)) == min_pmu

  pmu_test_new = pmu_test;
  pmu_test_new(idx4) = [];
  if ishandle(Fig.pmu)
    set(hdl_pmu,'String',int2str(test_len-length(pmu_test3)));
    drawnow
  end
  linee = [Line.fr, Line.to];
  I_idx = [];
  nodi = [];
  pseudoi = 0;

  for ijk = 1:length(pmu_test_new)
    i_idx = fm_iidx(pmu_test_new(ijk),linee);
    I_idx = [I_idx; i_idx];
    nodi_oss = [i_idx(:,4);pmu_test_new(ijk)];
    nodi = [nodi; nodi_oss];
    if ishandle(Fig.pmu)
      set(hdl_nob,'String',int2str(length(nodi)));
      drawnow
    end
  end

  linee(I_idx(:,2),[1 2]) = zeros(length(I_idx(:,1)),2);

  % determinazione delle pseudo-correnti  determinate con
  % la legge di Kirchhoff per le correnti
  % ed eliminazione dei nodi di cui si pu determinare la
  % tensione con la legge di Ohm
  % determinazione delle pseudo-correnti nelle linee ai cui
  % estremi sono note le tensioni
  for ii = 1:length(nodi)
    I_idx_from = find(linee(:,1) == nodi(ii));
    if ~isempty(I_idx_from)
      I_idx_to = [];
      for jj = 1:length(I_idx_from)
        if ~isempty(find(nodi == linee(I_idx_from(jj),2)))
          I_idx_to = [I_idx_to; I_idx_from(jj)];
        end
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
        if ishandle(Fig.pmu)
          set(hdl_nob,'String',int2str(length(nodi)));
          drawnow
        end
        % dopo l'aggiunta di un nuovo nodo misurato bisogna
        % ricontrollare tutti i nodi
        count = 1;

        % ricerca di pseudo-correnti che possono essere misurate
        % con il nodo aggiunto
        for ii = 1:length(nodi)
          I_idx_from = find(linee(:,1) == nodi(ii));
          if ~isempty(I_idx_from)
            I_idx_to = [];
            for jj = 1:length(I_idx_from)
              if ~isempty(find(nodi == linee(I_idx_from(jj),2)))
                I_idx_to = [I_idx_to; I_idx_from(jj)];
              end
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
        end

      else
        count = count + 1;
      end
    else
      count = count + 1;
    end
  end

  nodi_ord = sort(nodi);
  num_nodi = length(nodi);
  nodi_el = [];
  for jjj = 1:num_nodi
    nodi_el = [nodi_el; jjj+find(nodi_ord([jjj+1:num_nodi]) == ...
                                 nodi_ord(jjj))];
  end
  nodi_ord(nodi_el) = [];
  if ishandle(Fig.pmu)
    set(hdl_nob,'String',int2str(Bus.n-length(nodi_ord)));
    drawnow
  end

  if length(nodi_ord) == Bus.n
    pmu_test2(sel_pmu) = [];
    pmu_status(sel_pmu) = [];
    a = cell(1,1);
    a{1,1} = pmu_test_new;
    pmu_test2 = [a; pmu_test2];
    a{1,1} = I_idx;
    I_idx_test = [a; I_idx_test];
    a{1,1} = pseudoi;
    pseudi_test = [a; pseudi_test];
    pmu_status = [1; pmu_status];
  else
    pmu_test2(sel_pmu) = [];
    I_idx_test(sel_pmu) = [];
    pseudi_test(sel_pmu) = [];
    pmu_status(sel_pmu) = [];
  end

else

  if length(pmu_test2{sel_pmu}) > min_pmu
    pmu_test2(sel_pmu) = [];
    I_idx_test(sel_pmu) = [];
    pseudi_test(sel_pmu) = [];
    pmu_status(sel_pmu) = [];
  else
    pmu_status(sel_pmu) = 1;
  end

end