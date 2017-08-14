function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

for i = 1:length(idx)
  jdx = find(a.ty1 == idx(i));
  if jdx
    a.ty1(jdx) = [];
    a.bcv(jdx,:) = [];
  end
  jdx = find(a.ty2 == idx(i));
  if jdx
    a.ty2(jdx) = []; 
    a.alpha(jdx,:) = [];
    a.vm(jdx,:) = [];
  end  
end

a.con(idx,:) = [];
a.bus(idx) = [];
a.vbus(idx) = [];
a.u(idx) = [];
a.n = a.n - length(idx);
a.Be(idx,:) = [];
a.vref(idx,:) = [];
a.q(idx,:) = [];
