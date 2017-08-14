function [qx,qn] = suqlim(a,Qmax,Qmin,bus)

if ~a.n
  qx = [];
  qn = [];
  return
end

qx = zeros(a.n, 1);
qn = zeros(a.n, 1);

for i = 1:length(bus)
  idx = find(a.bus == bus(i));
  if isempty(idx), continue, end
  qx(idx) = a.u(idx).*a.con(idx,16)+1e-8*(~a.u(idx));
  qn(idx) = a.u(idx).*a.con(idx,17);
  maxq = sum(abs(a.u(idx).*a.con(idx,16)));
  minq = sum(abs(a.u(idx).*a.con(idx,17)));
  if maxq == 0
    qx(idx) = (Qmax(i)/length(idx))*a.u(idx)+1e-8*(~a.u(idx)); 
  end
  if minq == 0
    qn(idx) = (Qmin(i)/length(idx))*a.u(idx); 
  end
end

