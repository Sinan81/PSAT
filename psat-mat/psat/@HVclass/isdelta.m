function out = isdelta(a,idx)

global DAE Settings

out = 0;

if ~a.n, return, end

if Settings.hostver > 7
  out1 = ~isempty(find((DAE.n + a.u.*a.phir) == idx,1));
  out2 = ~isempty(find((DAE.n + a.u.*a.phii) == idx,1));
else
  out1 = ~isempty(find((DAE.n + a.u.*a.phir) == idx));
  out2 = ~isempty(find((DAE.n + a.u.*a.phii) == idx));
end

out = out1 || out2;