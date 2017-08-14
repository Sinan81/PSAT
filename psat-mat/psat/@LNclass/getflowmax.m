function out = getflowmax(a,type)

global Settings

out = [];

if ~a.n, return, end

switch type
 case {'imax',1}
  out = a.con(:,13);
 case {'pmax',2}
  out = a.con(:,14);
 case {'smax',3}
  out = a.con(:,15);
end

idx = find(out <= 0);
if ~isempty(idx)
  out(idx) = 1e6*Settings.mva;
end
