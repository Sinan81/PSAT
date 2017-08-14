function [Syneq,pf] = equiv(a,borderbus,gengroups,yi)

global Bus DAE Settings

idx = [];
for i = 1:length(borderbus)
  if isempty(gengroups{i})
    idx = [idx; i];
  end
end
borderbus(idx) = [];
gengroups(idx) = [];
yi(idx) = [];
nborder = length(borderbus);

% participation factors
pf = cell(nborder,1);
for h = 1:nborder
  vj = DAE.y(borderbus(h)+Bus.n)*exp(sqrt(-1)*DAE.y(borderbus(h)));
  gen = gengroups{h};
  yij = yi{h};
  pfh = zeros(length(gen),1);
  for i = 1:length(gen)
    gbus = a.bus(gen(i));
    vi = DAE.y(gbus+Bus.n)*exp(sqrt(-1)*DAE.y(gbus));
    sij = vi*conj((vi-vj)*yij(i));
    pfh(i) = abs(real(sij)/a.Pg0(gen(i)));
  end
  pf{h} = pfh;
end

% equivalent machine data (one per border bus)
Syneq = zeros(nborder,28);
Syneq(:,1) = borderbus+Bus.n; % bus index
Syneq(:,3) = getkv(Bus,borderbus,1); % voltage rating
for i = 1:nborder
  gen = gengroups{i};
  Syneq(i,4) = mean(a.con(gen,4));
  Syneq(i,5) = min(a.con(gen,5));
end
Syneq(:,22) = 1;
Syneq(:,23) = 1;
Syneq(:,27) = 1;
Syneq(:,28) = 1;

for h = 1:nborder
  hh = gengroups{h};
  kvs = a.con(hh,3);
  kveq = Syneq(h,3);
  mvas = a.con(hh,2);
  mvaeq = sum(pf{h}.*mvas); % power rating
  if mvaeq == 0
    mvaeq = 1;
  end
  Syneq(h,2) = mvaeq;
  if Settings.conv
    Hs = pf{h}.*a.con(hh,18)*Settings.mva/mvaeq; % inertias
    Syneq(h,19) = sum(pf{h}.*a.con(hh,19)*Settings.mva/mvaeq); % damping
  else
    Hs = pf{h}.*a.con(hh,18).*mvas/mvaeq; % inertias
    Syneq(h,19) = sum(pf{h}.*a.con(hh,19).*mvas/mvaeq); % damping
  end
  if sum(Hs) == 0
    sumHs = 1;
  else
    sumHs = sum(Hs);
  end
  Syneq(h,18) = sum(Hs); % equivalent inertia
  Syneq(h,11) = sum(Hs.*a.con(hh,11))/sumHs; % T'd0
  Syneq(h,12) = sum(Hs.*a.con(hh,12))/sumHs; % T"d0
  Syneq(h,16) = sum(Hs.*a.con(hh,16))/sumHs; % T'q0
  Syneq(h,17) = sum(Hs.*a.con(hh,17))/sumHs; % T"q0
  udx = [6:10, 13:15];
  Vb2new = a.con(hh,3).*a.con(hh,3);
  if Settings.conv
    Vb2old = getkv(Bus,a.bus(hh),2);
    k = mvas.*Vb2old./Vb2new/Settings.mva;
  else
    k = ones(length(hh),1);
  end
  for u = 1:length(udx)
    uu = udx(u);
    % resistances and reactances
    Syneq(h,uu) = sum(Hs.*a.con(hh,uu).*k)/sumHs;
  end
end
