function [pmu_test, I_idx, pseudoi] = fm_pmuloc
% FM_PMULOC main function for PMU placement routines
%
% (PMU,I,PSEUDO_I) = FM_PMULOC
%      PMU placement set
%      I   measured currents
%      PSEUDO_I indirectly measured currents
%
% see also FM_PMUFIG
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Line Bus DAE Settings PMU
global Ltc File Path Fig

if ~Line.n
  fm_disp('No static network is loaded. PMU placement interrupted.')
  return
end

tic

  if ishandle(Fig.pmu)
    hdl_pmv = findobj(Fig.pmu,'Tag','ListboxPMV');
    hdl_ang = findobj(Fig.pmu,'Tag','ListboxANG');
    hdl_V   = findobj(Fig.pmu,'Tag','ListboxV');
    hdl_pmc = findobj(Fig.pmu,'Tag','StaticTextPMC');
    hdl_pmu = findobj(Fig.pmu,'Tag','StaticTextPMU');
    hdl_nob = findobj(Fig.pmu,'Tag','StaticTextNOB');
    hdl_mv  = findobj(Fig.pmu,'Tag','StaticTextMV');
    hdl_mc  = findobj(Fig.pmu,'Tag','StaticTextMC');
  else
    hdl_pmv = 0;
    hdl_ang = 0;
    hdl_V   = 0;
    hdl_pmc = 0;
    hdl_pmu = 0;
    hdl_nob = 0;
    hdl_mv  = 0;
    hdl_mc  = 0;
  end

  type = PMU.method;

  fm_disp(' ',1)
  fm_disp('PMU Placement Routine',1)
  fm_disp(['Data File "',Path.data,File.data,'"'],1)

  oldg = DAE.g;
  fm_call('series')
  roundg = round(abs(DAE.g)/Settings.lftol)*Settings.lftol;
  DAE.g = oldg;
  zeroinj = roundg(Bus.a)+roundg(Bus.v);

  % vettore contenente i bus a cui si collocano i PMU
  pmu_con = [];
  % indice delle correnti misurate:
  % I_idx => [#corrente, #linea, from bus, to bus, sign]
  I_idx = [];

  % conteggio delle connessioni e ordinamento dei nodi
  nodi = [Line.fr; Line.to];
  n_link = zeros(Bus.n,2);
  for i = 1:Bus.n
    a = find(nodi == getidx(Bus,i));
    n_link(i,:) = [getidx(Bus,i),length(a)];
  end
  [y,i] = sort(n_link(:,2));
  n_link = n_link(i,:);
  linee = [Line.fr, Line.to];
  pseudoi = 0;

  switch type

   case 1  % depth first method

    metodo = 'Depth First';
    fm_disp([metodo, ' Method '],1)

    while length(n_link(:,1)) > 0
      % locazione del PMU nel nodo non osservabile pi interconnesso
      pmu_con = [pmu_con; n_link(length(n_link(:,1)),1)];
      i_idx = fm_iidx(pmu_con(length(pmu_con)),linee);
      I_idx = [I_idx; i_idx];
      % nodi osservabili dal primo PMU
      nodi_oss = [i_idx(:,4);pmu_con(length(pmu_con))];
      a = [];
      for i = 1:length(nodi_oss)
        a = [a; find(n_link(:,1) == nodi_oss(i))];
      end
      if ~isempty(a); n_link(a,:) = []; end
      if ishandle(Fig.pmu)
        set(hdl_pmu,'String',int2str(length(pmu_con)));
        set(hdl_nob,'String',int2str(length(n_link(:,1))));
        drawnow
      end
    end
    pmu_test = pmu_con;

   case 2  % depth first method with pseudo measurement of voltages and currents

    metodo = 'Graph Theoretic Procedure';
    fm_disp([metodo, ' Method '],1)

    nodi = [];
    while length(n_link(:,1)) > 0
      % locazione del PMU nel nodo non osservabile pi interconnesso
      pmu_con = [pmu_con; n_link(length(n_link(:,1)),1)];
      i_idx = fm_iidx(pmu_con(length(pmu_con)),linee);

      if ~isempty(i_idx)
        I_idx = [I_idx; i_idx];
        % nodi osservabili dal primo PMU
        nodi_oss = [i_idx(:,4); pmu_con(length(pmu_con))];
        nodi = [nodi; nodi_oss];
        linee(i_idx(:,2),[1 2]) = zeros(length(nodi_oss)-1,2);
      end

      % determinazione delle pseudo-correnti determinate con la
      % legge di Kirchhoff per le correnti ed eliminazione dei nodi
      % di cui si pu determinare la tensione con la legge di Ohm

      % determinazione delle pseudo-correnti nelle linee ai cui
      % estremi sono note le tensioni
      for ii = 1:length(nodi)
        I_idx_fr = find(linee(:,1) == nodi(ii));
        I_idx_to = [];
        for jj = 1:length(nodi)
          ifrom = find(linee(I_idx_fr,2) == nodi(jj));
          I_idx_to = [I_idx_to; I_idx_fr(ifrom)];
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
          I_idx_fr = find(linee(:,1) == nodi(count));
          I_idx_to = find(linee(:,2) == nodi(count));
          ncfrom = length(I_idx_fr);
          ncto = length(I_idx_to);
          nc = ncfrom + ncto;
          if nc == 1
            if ncfrom == 1
              ki_idx = [1, I_idx_fr, linee(I_idx_fr,[1 2]), 1];
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

            % ricerca di pseudo-correnti che possono essere
            % misurate con il nodo aggiunto
            for ii = 1:length(nodi)
              I_idx_fr = find(linee(:,1) == nodi(ii));
              I_idx_to = [];
              for jj = 1:length(nodi)
                ifrom = find(linee(I_idx_fr,2) == nodi(jj));
                I_idx_to = [I_idx_to; I_idx_fr(ifrom)];
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
      for i = 1:length(nodi_oss)
        a = [a; find(n_link(:,1) == nodi_oss(i))];
      end
      if ~isempty(a); n_link(a,:) = []; end
      if ishandle(Fig.pmu)
        set(hdl_pmu,'String',int2str(length(pmu_con)));
        set(hdl_nob,'String',int2str(length(n_link(:,1))));
        drawnow
      end
    end
    pmu_test = pmu_con;

   case 3  % annealing method

    metodo = 'Annealing Method';
    fm_disp([metodo, ' Method '],1)

    nodi = [];
    ok = 1;

    while length(n_link(:,1)) > 0
      % locazione del PMU nel nodo non osservabile pi interconnesso
      pmu_con = [pmu_con; n_link(length(n_link(:,1)),1)];
      i_idx = fm_iidx(pmu_con(length(pmu_con)),linee);

      if ~isempty(i_idx)
        I_idx = [I_idx; i_idx];
        nodi_oss = [i_idx(:,4);pmu_con(length(pmu_con))];
        nodi = [nodi; nodi_oss];
        linee(i_idx(:,2),[1 2]) = zeros(length(nodi_oss)-1,2);
      end

      % determinazione delle pseudo-correnti  determinate con la
      % legge di Kirchhoff per le correnti ed eliminazione dei nodi
      % di cui si pu determinare la tensione con la legge di Ohm

      % determinazione delle pseudo-correnti nelle linee ai cui
      % estremi sono note le tensioni
      for ii = 1:length(nodi)
        I_idx_fr = find(linee(:,1) == nodi(ii));
        I_idx_to = [];
        for jj = 1:length(nodi)
          ifrom = find(linee(I_idx_fr,2) == nodi(jj));
          I_idx_to = [I_idx_to; I_idx_fr(ifrom)];
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
          I_idx_fr = find(linee(:,1) == nodi(count));
          I_idx_to = find(linee(:,2) == nodi(count));
          ncfrom = length(I_idx_fr);
          ncto = length(I_idx_to);
          nc = ncfrom + ncto;
          if nc == 1
            if ncfrom == 1
              ki_idx = [1, I_idx_fr, linee(I_idx_fr,[1 2]), 1];
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

            % ricerca di pseudo-correnti che possono essere
            % misurate con il nodo aggiunto
            for ii = 1:length(nodi)
              I_idx_fr = find(linee(:,1) == nodi(ii));
              I_idx_to = [];
              for jj = 1:length(nodi)
                ifrom = find(linee(I_idx_fr,2) == nodi(jj));
                I_idx_to = [I_idx_to; I_idx_fr(ifrom)];
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
      for i = 1:length(nodi_oss)
        a = [a; find(n_link(:,1) == nodi_oss(i))];
      end
      if ~isempty(a); n_link(a,:) = []; end
      if ishandle(Fig.pmu)
        set(hdl_pmu,'String',int2str(length(pmu_con)));
        set(hdl_nob,'String',int2str(length(n_link(:,1))));
        drawnow
      end
    end

    pmu_test = pmu_con;
    pmu_test_old = pmu_con;
    I_idx_old = I_idx;
    pseudoi_old = pseudoi;
    nu = length(pmu_con);
    nl = 0;

    while (nu - nl) > 1 && nu > 1

      if nl == 0
        ntest = fix(0.85*nu);
      else
        ntest = fix((nu+nl)/2);
      end
      pmurand = randperm(nu);
      pmu_test = pmu_test_old(pmurand(1:ntest));

      % inizio della procedura di annealing
      linee = [Line.fr, Line.to];
      I_idx = [];
      nodi = [];
      pseudoi = 0;

      for ii = 1:ntest
        i_idx = fm_iidx(pmu_test(ii),linee);

        if ~isempty(i_idx)
          I_idx = [I_idx; i_idx];
          % nodi osservabili dal primo PMU
          nodi_oss = [i_idx(:,4);pmu_test(ii)];
          nodi = [nodi; nodi_oss];
          linee(i_idx(:,2),[1 2]) = zeros(length(nodi_oss)-1,2);
        end

        % determinazione delle pseudo-correnti nelle linee ai cui
        % estremi sono note le tensioni
        pi_idx = [];
        for i = 1:length(nodi)
          I_idx_fr = find(linee(:,1) == nodi(i));
          I_idx_to = [];
          for j = 1:length(nodi)
            ifrom = find(linee(I_idx_fr,2) == nodi(j));
            I_idx_to = [I_idx_to; I_idx_fr(ifrom)];
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
          % pmu_con(length(pmu_con));
          linee(pi_idx(:,2),[1 2]) = zeros(length(pi_idx(:,1)),2);
          I_idx = [I_idx; pi_idx];
          pseudoi = pseudoi + length(pi_idx(:,1));
        end

        % determinazione delle pseudo-correnti  determinate con la
        % legge di Kirchhoff per le correnti
        % ed eliminazione dei nodi di cui si pu determinare la
        % tensione con la legge di Ohm
        count = 1;
        while count < length(nodi)
          %for ii = 1:length(nodi)
          if zeroinj(Bus.int(nodi(count))) == 0
            I_idx_fr = find(linee(:,1) == nodi(count));
            I_idx_to = find(linee(:,2) == nodi(count));
            ncfrom = length(I_idx_fr);
            ncto = length(I_idx_to);
            nc = ncfrom + ncto;
            if nc == 1
              if ncfrom == 1
                ki_idx = [1, I_idx_fr, linee(I_idx_fr,[1 2]), 1];
              else
                ki_idx = [1, I_idx_to, linee(I_idx_to,[2 1]), -1];
              end
              linee(ki_idx(2),[1 2]) = zeros(length(ki_idx(1)),2);
              I_idx = [I_idx; ki_idx];
              pseudoi = pseudoi + length(ki_idx(1));
              nodi_oss = [nodi_oss; ki_idx(4)];
              nodi = [ki_idx(4); nodi];
              count = 1;
            else
              count = count + 1;
            end
          else
            count = count + 1;
          end
        end

      end

      I_idx(:,1) = [1:length(I_idx(:,1))]';
      [Vest, angest, rangoH] = fm_lssest(pmu_test, I_idx,0);
      [nu, nl, pmu_test, I_idx, pseudoi, ok] = ...
          fm_annealing(rangoH, ntest, pmu_test, nu, nl, hdl_nob, zeroinj);
      if ok
        pmu_test_old = pmu_test;
        I_idx_old = I_idx;
        pseudoi_old = pseudoi;
        if ishandle(Fig.pmu)
          set(hdl_pmu,'String',int2str(nu));
          set(hdl_nob,'String',int2str(0));
          drawnow
        end
      end
    end

    if ~ok
      pmu_test = pmu_test_old;
      I_idx = I_idx_old;
      pseudoi = pseudoi_old;
    end
    if ishandle(Fig.pmu), set(hdl_nob,'String',int2str(0)); end

   case 4

    metodo = 'Minimum Spanning Tree';
    fm_disp([metodo, ' Method '],1)
    [pmuloc, pmunum] = fm_mintree(zeroinj,hdl_pmu,hdl_nob);
    [pmu_test, pmu_test2, I_idx, pseudoi, index_pmu, pmunum] = ...
        fm_spantree(zeroinj, pmuloc, pmunum, hdl_pmu, hdl_nob);

   case 5

    metodo = 'Direct Spanning Tree';
    fm_disp([metodo, ' Method '],1)
    pesi = zeros(1,Bus.n);
    coll = zeros(1,Bus.n);

    % costruzione della matrice di adiacenza di rete
    A = zeros(Bus.n,Bus.n);
    for i = 1:Bus.n
      nonzero = find(Line.Y(i,:));
      A(i,nonzero) = ones(1,length(nonzero));
      A(i,i) = 0;
      coll(i) = sum(A(i,:));
    end

    % posizionamento dei PMU nei nodi collegati alle
    % antenne (interconnessione singola)
    pmu_test = [];
    coll1_idx = find(coll == 1);
    for i = 1:length(coll1_idx)
      pmu_idx = find(A(coll1_idx(i),:));
      pmu_test = [pmu_test, getidx(Bus,pmu_idx)];
      if ishandle(Fig.pmu)
        set(hdl_pmu,'String',int2str(length(pmu_test)));
        set(hdl_nob,'String',int2str(length(find(pesi == 0))));
        drawnow
      end
      pesi(pmu_idx) = 100;
      pmu_idx = find(A(pmu_idx,:));
      pesi(pmu_idx) = pesi(pmu_idx) + ones(1,length(pmu_idx));
    end

    % posizionamento dei PMU, nodi ad interconnessione maggiore di 1
    max_coll = max(coll);
    j = 2;
    while 1
      n_pmu = length(pmu_test);
      basta = 1;
      coll_idx = find(coll == j && pesi == 0);
      for i = 1:length(coll_idx)
        pmu_idx = find(A(coll_idx(i),:));
        a = find(pesi(pmu_idx) >= 1);
        b = find(pesi(pmu_idx) == 0);
        if length(b) == 1 && isempty(find(pesi(pmu_idx(a)) > 99))
          basta = 0;
          break
        end
      end
      if basta,
        j = j + 1;
        if j > max_coll, break, end
      else
        pesi(pmu_idx(a)) = pesi(pmu_idx(a)) + ones(1,length(pmu_idx(a)));
        pesi(pmu_idx(b)) = 100;
        pmu_test = [pmu_test,getidx(Bus,pmu_idx(b))];
        if ishandle(Fig.pmu)
          set(hdl_pmu,'String',int2str(length(pmu_test)));
          set(hdl_nob,'String',int2str(length(find(pesi == 0))));
          drawnow
        end
        pmu_idx2 = find(A(pmu_idx(b),:));
        pesi(pmu_idx2) = pesi(pmu_idx2) + ones(1,length(pmu_idx2));
      end
      if n_pmu < length(pmu_test), j = 2; end
    end

    % assegnazione di un PMU ai nodi non ancora osservabili
    while 1
      a = find(pesi == 0);
      if isempty(a), break, end
      pmu_test = [pmu_test,getidx(Bus,a(1))];
      pesi(a(1)) = 100;
      pmu_idx2 = find(A(a(1),:));
      pesi(pmu_idx2) = pesi(pmu_idx2) + ones(1,length(pmu_idx2));
      if ishandle(Fig.pmu)
        set(hdl_pmu,'String',int2str(length(pmu_test)));
        set(hdl_nob,'String',int2str(length(find(pesi == 0))));
        drawnow
      end
    end

    pmuloc = zeros(1,Bus.n);
    pmuloc(Bus.int(pmu_test)) = 1; %ones(1,pmunum);
    pmunum = length(find(pmuloc));
    [pmu_test, pmu_test2, I_idx, pseudoi, index_pmu, pmunum] = ...
        fm_spantree(zeroinj, pmuloc, pmunum, hdl_pmu, hdl_nob);

   case 6

    metodo = 'Minimum (N-1) Spanning Tree';
    fm_disp([metodo, ' Method '],1)

    bus20 = zeros(Bus.n,1);
    bus0 = bus20;

    for i = 1:Bus.n
      bus2 = bus20;
      bus2(i) = 1;
      pmu_test = getidx(Bus,i);
      bus_pmu = getidx(Bus,i);
      while ~isempty(find(~bus2))
        buspmu_new = [];
        for j = 1:length(bus_pmu)
          [buspmu, bus2]= fm_pmurec(bus_pmu(j),bus2,bus0);
          buspmu_new = [buspmu_new; buspmu];
          pmu_test = [pmu_test; buspmu];
        end
        bus_pmu = buspmu_new;
      end
      pmu_test = sort(pmu_test);
      num_bus = length(pmu_test);
      nodi_el = [];
      antenne = [];
      for jjj = 1:length(pmu_test)
        nodi_el = [nodi_el; jjj+find(pmu_test([jjj+1:length(pmu_test)]) ...
                                     == pmu_test(jjj))];
      end

      pmu_test(nodi_el) = [];
      for jjj = 1:length(pmu_test)
        a = length(busidx(Line,pmu_test(jjj)));
        if a == 1, antenne = [antenne, jjj]; end
      end
      pmu_test(antenne) = [];
      for jjj = 1:Bus.n
        if isempty(find(pmu_test == getidx(Bus,jjj)))
          a = busidx(Line,getidx(Bus,jjj));
          if length(a) > 1
            a_idx = [];
            for kkk = 1:length(a)
              a_idx = [a_idx; find(pmu_test == a(kkk))];
            end
            if length(a_idx) < 2, pmu_test = [pmu_test; a]; end
          end
        end
      end
      nodi_el = [];
      for jjj = 1:length(pmu_test)
        nodi_el = [nodi_el; jjj+find(pmu_test([jjj+1:length(pmu_test)]) ...
                                     == pmu_test(jjj))];
      end

      pmu_test(nodi_el) = [];
      pmutest{i,1} = pmu_test;
      if ishandle(Fig.pmu)
        set(hdl_pmu,'String',int2str(length(pmu_test)));
        set(hdl_nob,'String',int2str(0));
        drawnow
      end
    end

    for i = 1:length(pmutest)

      pmu_test_new = pmutest{i};
      ntest = length(pmu_test_new);
      pmunum(i) = ntest;
      if ishandle(Fig.pmu)
        set(hdl_pmu,'String',int2str(ntest));
        drawnow
      end
      linee = [Line.fr,Line.to];

      I_idx = [];
      nodi = [];
      pseudoi = 0;

      % nodi osservabili dai PMU posizionati con l'algoritmo
      % di spanning tree
      for ijk = 1:ntest
        i_idx = fm_iidx(pmu_test_new(ijk),linee);
        I_idx = [I_idx; i_idx];
        nodi_oss = [i_idx(:,4);pmu_test_new(ijk)];
        nodi = [nodi; nodi_oss];
      end

      nodi = sort(nodi);
      num_nodi = length(nodi);
      nodi_el = [];
      for jjj = 1:num_nodi
        nodi_el = [nodi_el; jjj+find(nodi([jjj+1:num_nodi]) == ...
                                     nodi(jjj))];
      end
      nodi(nodi_el) = [];

      % determinazione delle pseudo-correnti nelle linee ai cui
      % estremi sono note le tensioni
      pi_idx = [];
      for ii = 1:length(nodi)
        I_idx_fr = find(linee(:,1) == nodi(ii));
        I_idx_to = [];
        for jj = 1:length(nodi)
          ifrom = find(linee(I_idx_fr,2) == nodi(jj));
          I_idx_to = [I_idx_to; I_idx_fr(ifrom)];
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

      % determinazione delle pseudo-correnti  determinate con
      % la legge di Kirchhoff per le correnti
      % ed eliminazione dei nodi di cui si pu determinare la
      % tensione con la legge di Ohm
      count = 1;
      while count < length(nodi)
        if zeroinj(Bus.int(nodi(count))) == 0
          I_idx_fr = find(linee(:,1) == nodi(count));
          I_idx_to = find(linee(:,2) == nodi(count));
          ncfrom = length(I_idx_fr);
          ncto = length(I_idx_to);
          nc = ncfrom + ncto;
          if nc == 1
            if ncfrom == 1
              ki_idx = [1, I_idx_fr, linee(I_idx_fr,[1 2]), 1];
            else
              ki_idx = [1, I_idx_to, linee(I_idx_to,[2 1]), -1];
            end
            linee(ki_idx(2),[1 2]) = zeros(length(ki_idx(1)),2);
            I_idx = [I_idx; ki_idx];
            pseudoi = pseudoi + length(ki_idx(1));
            nodi_oss = [nodi_oss; ki_idx(4)];
            nodi = [ki_idx(4); nodi];
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
      if ishandle(Fig.pmu)
        set(hdl_nob,'String',int2str(0));
        drawnow
      end
    end
    numpmu = Bus.n;
    numpmuold = Bus.n;
    index_pmu = [];
    for i = 1:length(pmu_test2)
      numpmu = min(numpmu, length(pmu_test2{i,1}));
    end
    for i = 1:length(pmu_test2),
      if numpmu == length(pmu_test2{i,1})
        index_pmu = [index_pmu; i];
      end
    end
    pmu_test = pmu_test2(index_pmu);
    I_idx = I_idx_test(index_pmu);
    pseudoi = pseudi_test(index_pmu);
    if ishandle(Fig.pmu)
      set(hdl_pmu,'String',int2str(pmunum(index_pmu(1))));
      set(hdl_nob,'String',int2str(0));
      drawnow
    end
    pmunum = numpmu;

   case 7

    metodo = 'Direct (N-1) Spanning Tree';
    fm_disp([metodo, ' Method '],1)
    pesi = zeros(1,Bus.n);
    coll = zeros(1,Bus.n);

    % costruzione della matrice di adiacenza di rete
    A = zeros(Bus.n,Bus.n);
    for i = 1:Bus.n
      nonzero = find(Line.Y(i,:));
      A(i,nonzero) = ones(1,length(nonzero));
      A(i,i) = 0;
      coll(i) = sum(A(i,:));
    end

    % posizionamento dei PMU nei nodi collegati alle
    % antenne (interconnessione singola)
    pmu_test = [];
    coll1_idx = find(coll == 1);
    for i = 1:length(coll1_idx)
      pmu_idx = find(A(coll1_idx(i),:));
      pmu_test = [pmu_test,getidx(Bus,pmu_idx)];
      if ishandle(Fig.pmu)
        set(hdl_pmu,'String',int2str(length(pmu_test)));
        set(hdl_nob,'String',int2str(length(find(pesi == 0))));
        drawnow
      end
      pesi(pmu_idx) = 100;
      pmu_idx = find(A(pmu_idx,:));
      pesi(pmu_idx) = pesi(pmu_idx) + ones(1,length(pmu_idx));
    end

    % posizionamento dei PMU, nodi ad interconnessione maggiore di 1
    max_coll = max(coll);
    j = 2;

    while 1
      n_pmu = length(pmu_test);
      coll_idx = find(coll == j && pesi < 100);
      for i = 1:length(coll_idx)
        pmu_idx = find(A(coll_idx(i),:));
        a = find(pesi(pmu_idx) >= 1);
        b = find(pesi(pmu_idx) > 99);
        if length(a) >= 1 && length(b) < round(2*j/3)
          %isempty(find(pesi(pmu_idx(a)) > 99))
          pmu_test = [pmu_test,getidx(Bus,coll_idx(i))];
          pesi(pmu_idx) = pesi(pmu_idx) + 1;
          pesi(coll_idx(i)) = 100;
        end
      end
      j = j + 1;
      if j > max_coll, break, end
    end

    % assenazione di un PMU ai nodi non raggiungibili due volte
    while 1
      a = find(pesi < 99);
      b = coll(a);
      [b, c] = sort(b);
      a = a(c);
      for i = length(a):-1:1
        coll_idx = find(A(a(i),:));
        stoppa = 1;
        if length(find(pesi(coll_idx) > 99)) < 2 && length(coll_idx) > 1
          pesi(a(i)) = pesi(a(i))+100;
          pmu_test = [pmu_test,getidx(Bus,a(i))];
          stoppa = 0;
          break
        end
      end
      if stoppa, break, end
    end

    % determinazione della matrice di incidenza delle correnti misurate
    ntest = length(pmu_test);
    if ishandle(Fig.pmu)
      set(hdl_pmu,'String',int2str(ntest));
      set(hdl_nob,'String',int2str(length(find(pesi == 0))));
      drawnow
    end
    linee = [Line.fr,Line.to];
    I_idx = [];
    nodi = [];
    pseudoi = 0;

    for ijk = 1:ntest
      i_idx = fm_iidx(pmu_test(ijk),linee);
      I_idx = [I_idx; i_idx];
      nodi_oss = [i_idx(:,4);pmu_test(ijk)];
      nodi = [nodi; nodi_oss];
    end

    nodi = sort(nodi);
    num_nodi = length(nodi);
    nodi_el = [];
    for jjj = 1:num_nodi
      nodi_el = [nodi_el; jjj+find(nodi([jjj+1:num_nodi]) == ...
                                   nodi(jjj))];
    end
    nodi(nodi_el) = [];

    % determinazione delle pseudo-correnti nelle linee ai cui
    % estremi sono note le tensioni
    pi_idx = [];
    for ii = 1:length(nodi)
      I_idx_fr = find(linee(:,1) == nodi(ii));
      I_idx_to = [];
      for jj = 1:length(nodi)
        ifrom = find(linee(I_idx_fr,2) == nodi(jj));
        I_idx_to = [I_idx_to; I_idx_fr(ifrom)];
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

    index_pmu = 1;

  end

  if iscell(pmu_test)
    I_idx{1}(:,1) = [1:length(I_idx{1}(:,1))]';
    [Vest, angest, rangoH] = fm_lssest(pmu_test{1}, I_idx{1},1);
  else
    I_idx(:,1) = [1:length(I_idx(:,1))]';
    [Vest, angest, rangoH] = fm_lssest(pmu_test, I_idx,1);
  end

  pmucell = cell(Bus.n,1);
  vcell = cell(Bus.n,1);
  angcell = cell(Bus.n,1);

  for i = 1:Bus.n
    angolo = round(angest(i)/Settings.lftol)*Settings.lftol;
    if angolo < 0
      segno = '-';
    else
      segno = ' ';
    end
    angcell{i,1} = [segno, num2str(abs(angolo))];
  end

  if ~iscell(pmu_test)
    pmunum = length(pmu_test);
  end
  pmucif = ceil(log10(pmunum))+2;
  b = '                             ';
  b = b(1:pmucif);

  if type < 4, index_pmu = 1; end
  Matrix = cell(3,1);
  if length(index_pmu) > 1
    Matrix{3,1} = zeros(Bus.n+2,length(index_pmu));
  else
    Matrix{3,1} = zeros(Bus.n,1);
  end

  for i = 1:Bus.n
    vcell{i,1} = num2str(Vest(i));
    if iscell(pmu_test)
      pmuyes = find(pmu_test{1} == getidx(Bus,i));
    else
      pmuyes = find(pmu_test == getidx(Bus,i));
    end
    pmuname = Bus.names{i};
    if ~isempty(pmuyes)
      a = [int2str(pmuyes(1)),'      '];
      a = a(1:pmucif);
      vcell{i,1} = ['PMU ',a,' # ', vcell{i,1}];
      angcell{i,1} = ['PMU ',a,' # ', angcell{i,1}];
      pmucell{i,1} = ['PMU ',a,' # ',pmuname];
      Matrix{3,1}(i,1) = 1;
    else
      vcell{i,1} = [b,'       ', vcell{i,1}];
      angcell{i,1} = [b,'       ', angcell{i,1}];
      pmucell{i,1} = [b,'       ',pmuname];
    end
  end

  if type >= 4 && length(index_pmu) > 1
    for k = 2:length(index_pmu)
      pmu_test = pmu_test2{index_pmu(k),1};
      for i = 1:Bus.n
        pmuyes = find(pmu_test == getidx(Bus,i));
        pmuname = Bus.names{i};
        if ~isempty(pmuyes)
          a = [int2str(pmuyes(1)),'      '];
          a = a(1:pmucif);
          pmucell{i,k} = ['PMU ',a,' # ',pmuname];
          Matrix{3,1}(i,k) = 1;
        else
          pmucell{i,k} = [b,'       ',pmuname];
        end
      end
    end
  end

  pmunum = pmunum(1);
  if iscell(pseudoi)
    pseudi = pseudoi{1};
  else
    pseudi = pseudoi;
  end
  if iscell(I_idx)
    measui = length(I_idx{1}(:,1)) - pseudoi{1};
  else
    measui = length(I_idx(:,1)) - pseudoi;
  end

  if ishandle(Fig.pmu)
    set(hdl_pmv,'String',pmucell,'Value',1);
    set(hdl_ang,'String',angcell,'Value',1);
    set(hdl_V,'String',vcell,'Value',1);
    set(hdl_pmc,'String',pseudi);
    set(hdl_mv,'String',num2str(pmunum));
    set(hdl_mc,'String',measui);
  end

  PMU.location = pmucell;
  PMU.angle = angcell;
  PMU.voltage = vcell;
  PMU.measv = pmunum;
  PMU.measc = measui;
  PMU.pseudo = pseudi;
  PMU.number = pmunum;
  PMU.noobs = 0;

  tempo = toc;
  secondi = rem(tempo,60);
  tempo = (tempo - secondi)/60;
  minuti = rem(tempo,60);
  ore = (tempo - minuti)/60;
  durata = [int2str(ore),'h   ',int2str(minuti),'m   ',num2str(secondi),'s'];


  % PMU report
  % ----------------------------------------------------------

  % Headings
  Header{1,1}{1,1} = 'PMU PLACEMENT REPORT';
  Header{1,1}{2,1} = ' ';
  Header{1,1}{3,1} = ['P S A T  ',Settings.version];
  Header{1,1}{4,1} = ' ';
  Header{1,1}{5,1} = 'Author:  Federico Milano, (c) 2002-2016';
  Header{1,1}{6,1} = 'e-mail:  federico.milano@ucd.ie';
  Header{1,1}{7,1} = 'website: faraday1.ucd.ie/psat.html';
  Header{1,1}{8,1} = ' ';
  Header{1,1}{9,1} = ['File:  ', Path.data,strrep(File.data,'(mdl)','.mdl')];
  Header{1,1}{10,1} = ['Date:  ',datestr(now,0)];
  Header{1,1}{11,1} = ' ';
  Header{1,1}{12,1} = ['Placement Method:  ', metodo];
  Header{1,1}{13,1} = ['Elapsed Time:      ', durata];

  Matrix{1,1} = [];
  Cols{1,1} = '';
  Rows{1,1} = '';

  % Network and PMU statistics
  Header{2,1} = 'STATISTICS';
  Cols{2,1} = '';
  Rows{2,1}{1,1} = 'Buses';
  Matrix{2,1}(1,1) = Bus.n;
  Rows{2,1}{2,1} = 'Lines';
  Matrix{2,1}(2,1) = Line.n;
  Rows{2,1}{3,1} = 'PMUs';
  Matrix{2,1}(3,1) = PMU.number;
  Rows{2,1}{4,1} = 'PMU Sets';
  Matrix{2,1}(4,1) = length(pseudoi);
  if type < 4 || length(index_pmu) == 1
    Rows{2,1}{5,1} = 'Meas. Currents';
    Matrix{2,1}(5,1) = PMU.measc;
    Rows{2,1}{6,1} = 'Pseudo-Meas. Currents';
    Matrix{2,1}(6,1) = PMU.pseudo;
  end

  % PMU Placement
  nconf = length(index_pmu);
  Header{3,1} = 'PMU PLACEMENT';
  Cols{3,1}{1,1} = 'Bus Name';
  for kk = 1:nconf
    Cols{3,1}{1,kk+1} = ['Set ',num2str(kk)];
  end
  Rows{3,1} = Bus.names;
  if nconf > 1
    Rows{3,1}{Bus.n+1,1} = 'MC';
    Rows{3,1}{Bus.n+2,1} = 'PMC';
    for k = 1:nconf
      Matrix{3,1}(Bus.n+1,k) = pseudoi{k,1};
      Matrix{3,1}(Bus.n+2,k) = length(I_idx{k}(:,1) - pseudoi{k,1});
    end
  end

  if nconf > 7
    uno = fix(nconf/7);
    due = rem(nconf,7);
    for i = 2:uno;
      Header{2+i,1} = 'PMU PLACEMENT';
      Rows{2+i,1} = Bus.names;
      Rows{2+i,1}{Bus.n+1,1} = 'MC';
      Rows{2+i,1}{Bus.n+2,1} = 'PMC';
      Cols{2+i,1}{1,1} = 'Bus Name';
      idx1 = (i-1)*7+1;
      idx2 = i*7;
      for kk = 1:7
        Cols{2+i,1}{1,kk+1} = ['Set ',num2str(kk+idx1-1)];
      end
      Matrix{2+i,1} = Matrix{3,1}(:,idx1:idx2);
    end
    if due
      Header{3+uno,1} = 'PMU PLACEMENT';
      Rows{3+uno,1} = Bus.names;
      Rows{3+uno,1}{Bus.n+1,1} = 'MC';
      Rows{3+uno,1}{Bus.n+2,1} = 'PMC';
      Cols{3+uno,1}{1,1} = 'Bus Name';
      idx1 = uno*7+1;
      idx2 = uno*7+due;
      for kk = 1:due
        Cols{3+uno,1}{1,kk+1} = ['Set ',num2str(kk+uno*7)];
      end
      Matrix{3+uno,1} = Matrix{3,1}(:,idx1:idx2);
    end
    Cols{3,1} = Cols{3,1}(1:8);
    Matrix{3,1} = Matrix{3,1}(:,1:7);
  end


  PMU.report.Matrix = Matrix;
  PMU.report.Header = Header;
  PMU.report.Cols = Cols;
  PMU.report.Rows = Rows;

  % End PMU report
  % -----------------------------------------------------------

  fm_disp(['PMU placement completed in ',durata],1)
  if Settings.beep, beep, end