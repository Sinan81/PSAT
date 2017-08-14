function xfirst_phs(a)

global DAE

if ~a.n, return, end

DAE.x(a.alpha) = 0;
DAE.x(a.Pm) = 0;
idx = find(~a.con(:,7));
if ~isempty(idx)
  warn_phs(a,idx,'Measurement time constant Tm cannot be 0. Tm = 1e-3 will be used.')
  a.con(idx,7) = 1e-3;
end

