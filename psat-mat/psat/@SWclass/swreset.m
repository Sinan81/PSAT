function a = swreset(a,idx)

if ~a.n, return, end

global Settings

if isnumeric(idx)
  a.pg(idx) = a.store(idx,10).*a.con(:,2)/Settings.mva;
elseif strcmp(idx,'all')
  a.pg = a.store(:,10).*a.con(:,2)/Settings.mva;  
end
