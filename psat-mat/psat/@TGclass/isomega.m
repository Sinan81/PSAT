function out = isomega(a,idx)

global Settings DAE

out = 0;

if ~a.n, return, end

if Settings.hostver > 7
  out = ~isempty(find((DAE.n+a.wref) == idx,1));
else
  out = ~isempty(find((DAE.n+a.wref) == idx));
end

