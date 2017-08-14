function out = tanphi(a)

out = zeros(a.n,1);
idx = find(a.con(:,3) ~= 0);
if idx
  out(idx) = a.u(idx).*a.con(idx,4)./a.con(idx,3);
end
