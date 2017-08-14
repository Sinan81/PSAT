function [borderbus,gengroups,yi,y0,zthvec] = equiv(a,fid)
% write equivalent transmission lines

global EQUIV Bus Shunt PQ PV SW Syn DAE Settings

buslist = EQUIV.buslist;
idx = [];
extbus = [];
borderbus = [];
yi = [];
y0 = [];

% find border buses and external buses
for i = 1:a.n
  idxfr = find(buslist == a.fr(i)*a.u(i));
  idxto = find(buslist == a.to(i)*a.u(i));
  if isempty(idxfr) || isempty(idxto) 
    extbus = [extbus; a.fr(i); a.to(i)];
    if ~isempty(idxfr), borderbus = [borderbus; a.fr(i)]; end
    if ~isempty(idxto), borderbus = [borderbus; a.to(i)]; end
    idx = [idx; i];
  end
end

% remove repetitions from external and border bus lists
extbus = unique(extbus);
nbus = length(extbus);
borderbus = unique(borderbus);
nborder = length(borderbus);
gengroups = cell(0,0);

fr = a.fr(idx);
to = a.to(idx);
nb = Bus.n;

chrg = 0.5*a.u(idx).*a.con(idx,10);
y = a.u(idx)./(a.con(idx,8) + j*a.con(idx,9));
ts = a.con(idx,11).*exp(j*a.con(idx,12)*pi/180);
ts2= ts.*conj(ts);

Ybus = sparse(fr,to,-y.*ts,nb,nb) + ...
       sparse(to,fr,-y.*conj(ts),nb,nb) + ...
       sparse(fr,fr,y+j*chrg,nb,nb)+ ...
       sparse(to,to,y.*ts2+j*chrg,nb,nb);

% Ybus connectivity
connect_mat = ... 
    sparse(fr,fr,1,nb,nb) + ...
    sparse(fr,to,1,nb,nb) + ...
    sparse(to,to,1,nb,nb) + ...
    sparse(to,fr,1,nb,nb);

R = triu(connect_mat);

% define islands of external network buses
busgroups = cell(0,0);
i = 1;
while 1
  nr = 0;
  nr_new = length(R(:,1));
  while nr_new ~= nr
    nr = nr_new;
    idx = [];
    idxi = find(R(i,:));
    for k = i+1:nr
      idxk = find(R(k,:));
      if ~isempty(intersect(idxi,idxk))
        idxi = union(idxi,idxk);
        idx = [idx,k];
      end
    end
    if ~isempty(idx)
      R(i,idxi) = 1;
      R(idx,:) = [];
    end
    nr_new = length(R(:,1));
  end
  if length(idxi) == 1
    if isempty(find(buslist == idxi))
      disp(['Bus ',num2str(idxi),' is an isolated external bus.'])
      busgroups{end+1} = idxi;
    end
  else
    if ~isempty(idxi)
      busgroups{end+1} = unique(idxi);
    end
  end
  i = i + 1;
  if i > length(R(:,1)), break, end
end

% find buses per island
nisland = length(busgroups);
if nisland > 1
  fm_disp(['The external network is composed of ',num2str(nisland),' islands.'])
else
  fm_disp('The external network is interconnected.')
end

% check for missing connections (0 diagonal elements)
% This is necessary since the external network can be non-interconnected
b = find(diag(Ybus) == 0);
if ~isempty(b), Ybus = Ybus + sparse(b,b,1,nb,nb); end

% completing the Ybus
Ybus = Ybus - sparse(1:nb,1:nb,sqrt(-1)*1e-6,nb,nb);
Ybus = Ybus + ybus(Shunt,buslist);
Ybus = Ybus + ybus(PQ,buslist);

xbus = borderbus + Bus.n;

switch EQUIV.equivalent_method
  
 case 1 % Thevenin 
  
  % add generators internal impedance 
  Ybus = Ybus + ybus(Syn,buslist);
  
  % compute the equivalent Thevenin impedances at border buses
  zth = zeros(nborder,1);
  for h = 1:nborder
    i = borderbus(h);
    for hh = 1:nisland
      jj = find(busgroups{hh} == i);
      if ~isempty(jj)
        kk = busgroups{hh};
        ii = kk(jj);
        kk(jj) = [];
        icc = Ybus(ii,ii) - Ybus(ii,kk)*(Ybus(kk,kk)\Ybus(kk,ii));
        zth(h) = 1/icc;
        if abs(zth(h)) > 10
          zth(h) = sqrt(-1)*1e-5;
        end
        break
      end
    end
  end

  % check values of Thevenin impedances
  nozth = find(~abs(zth));
  if ~isempty(nozth)
    jay = sqrt(-1);
    for i = 1:length(nozth);
      h = nozth(i);
      k = borderbus(h);
      disp(['Warning: Bus "',Bus.names{k},'" has zero Thevenin impedance.'])
      zth(h) = jay*1e-3;
    end
  end
  
 case 2 % REI

  fm_disp('Defining REI equivalents.')
  
  % compute REI equivalents
  gengroups = cell(nborder,1);
  y0 = zeros(nborder,1);
  yi = cell(nborder,1);
  zth = zeros(nborder,1);
  for h = 1:nborder
    i = borderbus(h);
    for hh = 1:nisland
      jj = find(busgroups{hh} == i);        
      if ~isempty(jj)
        kk = busgroups{hh};
        ii = kk(jj);
        kk(jj) = [];
        % look for generator buses
        udx = [];
        gdx = [];
        for u = 1:length(kk)
          sdx = findbus(Syn,kk(u));
          % sdx = [sdx; findbus(PV, kk(u))];
          % sdx = [sdx; findbus(SW, kk(u))];
          if ~isempty(sdx)
            udx = [udx; u];
            gdx = [gdx; sdx];
          end
        end
        gengroups{h} = gdx;
        
        % compute REI equivalent
        Yt = Ybus(busgroups{hh},busgroups{hh});
        r = [udx;jj];
        c = 1:length(busgroups{hh});
        c(r) = [];
        Yr = Yt(r,r)-Yt(r,c)*(Yt(c,c)\Yt(c,r));
        y0(h) = -sum(Yr(end,1:end));
        yi{h} = -Yr(1:end-1,end);
        if sum(yi{h}) == 0
          yi{h} = -sqrt(-1)*1e-3*ones(length(r)-1,1);
        end
        % compute z_equivalent at border buses
        zth(h) = 1/sum(yi{h});          
        if abs(zth(h)) > 10
          zth(h) = sqrt(-1)*1e-5;
        end
        break
      end
    end
  end

  % write shunt of REI equivalent
  shdata = zeros(nborder,7);
  shdata(:,1) = xbus;
  shdata(:,2) = Settings.mva;
  shdata(:,3) = getkv(Bus,borderbus,1);
  shdata(:,4) = 50;
  shdata(:,5) = -real(y0);
  % shdata(:,6) = -imag(y0);
  shdata(:,7) = 1;
  Shunteq = SHclass;
  Shunteq.con = shdata;
  Shunteq.bus = xbus;
  Shunteq.u = ones(nborder,1);
  Shunteq.n = nborder;
  write(Shunteq,fid,xbus)
  
end

% write equivalent transmission ac line data
lndata = zeros(nborder,16);
lndata(:,1) = borderbus;
lndata(:,2) = xbus;
lndata(:,3) = Settings.mva;
lndata(:,4) = getkv(Bus,borderbus,1);
lndata(:,5) = 50;
lndata(:,8) = real(zth);
lndata(:,9) = imag(zth);
lndata(:,16) = 1;
Lineeq = LNclass;
Lineeq.con = lndata;
Lineeq.fr = borderbus;
Lineeq.to = xbus;
Lineeq.u = ones(nborder,1);
Lineeq.n = nborder;
write(Lineeq,fid,[borderbus;xbus])

zthvec = zeros(length(buslist),1);
idxb = ismember(buslist,borderbus);
zthvec(find(idxb)) = zth;
