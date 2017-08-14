function a = noqlim(a,idx)

global Settings

if isnumeric(idx)
  a.con(idx,6) = 999*Settings.mva;
  a.con(idx,7) = -999*Settings.mva;
elseif strcmp(idx,'all')
  a.con(:,6) = 999*Settings.mva;
  a.con(:,7) = -999*Settings.mva;
end
