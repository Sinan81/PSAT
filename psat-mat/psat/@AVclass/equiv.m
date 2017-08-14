function AVReq = equiv(a,gengroups,pf,n)

global Syn Settings

AVReq = [];

if ~a.n, return, end

ngen = length(gengroups);

AVReq = zeros(ngen,14);
AVReq(:,1) = n + [1:ngen]';
AVReq(:,2) = 2;
AVReq(:,14) = 1;

adx = [];

for i = 1:ngen
  hh = gengroups{i};
  idx = find(ismember(a.syn,hh));

  mvas = getvar(Syn,hh,'mva');
  M = getvar(Syn,hh,'M');
  mvaeq = sum(pf{i}.*mvas); % power rating
  if mvaeq == 0
    mvaeq = 1;
  end
  if Settings.conv
    Hs = pf{i}.*M*Settings.mva/mvaeq; % inertias
  else
    Hs = pf{i}.*M.*mvas/mvaeq; % inertias
  end
  
  Hs = Hs(find(ismember(hh,a.syn)));
  sumHs = sum(Hs);
  if isempty(Hs) || isempty(idx)
    adx = [adx; i];
    continue
  end
  AVReq(i,3) = sum(Hs.*a.con(idx,3))/sumHs;
  AVReq(i,4) = sum(Hs.*a.con(idx,4))/sumHs;
  AVReq(i,5) = sum(Hs.*a.con(idx,5))/sumHs;
  AVReq(i,6) = sum(Hs.*a.con(idx,6))/sumHs;
  AVReq(i,7) = sum(Hs.*a.con(idx,7))/sumHs;
  AVReq(i,8) = sum(Hs.*a.con(idx,8))/sumHs;
  AVReq(i,10) = sum(Hs.*a.con(idx,10))/sumHs;
  AVReq(i,11) = sum(Hs.*a.con(idx,11))/sumHs;
  AVReq(i,12) = sum(Hs.*a.con(idx,12))/sumHs;
  AVReq(i,13) = sum(Hs.*a.con(idx,13))/sumHs;
end

if ~isempty(adx)
  AVReq(adx,:) = [];
end
