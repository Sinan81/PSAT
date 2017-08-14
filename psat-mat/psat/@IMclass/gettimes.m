function t = gettimes(a)

t = [];

if ~a.n, return, end 

u = unique(a.con(:,18).*(~a.z).*a.u);
u(find(u == 0)) = [];
if isempty(u)
  t = [];
else
  t = [u-1e-6; u]
end
