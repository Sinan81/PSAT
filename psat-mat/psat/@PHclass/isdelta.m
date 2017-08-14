function out = isdelta(a,idx)

global Settings

out = 0;

if ~a.n, return, end

if Settings.hostver > 7
  out = ~isempty(find(a.u.*a.alpha == idx,1));
else
  out = ~isempty(find(a.u.*a.alpha == idx));
end