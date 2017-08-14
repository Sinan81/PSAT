function out = isdelta(a,idx)

global DAE Settings

out = 0;

if ~a.n, return, end

if Settings.hostver > 7
  out = ~isempty(find((DAE.n+a.delta) == idx,1));
else
  out = ~isempty(find((DAE.n+a.delta) == idx));
end