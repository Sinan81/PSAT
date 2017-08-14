function traceY = gettrace(a,traceY)

if ~a.n, return, end

idx = find(a.u);

if ~isempty(idx)
  traceY(a.bus1(idx)) = 1;
  traceY(a.bus2(idx)) = 1;
end
