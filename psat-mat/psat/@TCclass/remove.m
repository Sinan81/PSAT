function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

for i = 1:length(idx)
  jdx = find(a.ty1 == idx(i));
  if jdx 
    a.ty1(jdx) = [];
  end
  jdx = find(a.ty2 == idx(i));
  if jdx 
    a.ty2(jdx) = [];
    a.x2(jdx) = [];
  end  
end

a.con(idx,:) = [];
a.bus1(idx) = [];
a.bus2(idx) = [];
a.v1(idx) = [];
a.v2(idx) = [];
a.line(idx) = [];
a.n = a.n - length(idx);
a.x1(idx,:) = [];
a.B(idx,:) = [];
a.Cp(idx,:) = [];
a.X0(idx,:) = [];
a.Pref(idx,:) = [];
a.x0(idx,:) = [];
a.pref(idx,:) = [];
a.y(idx,:) = [];
a.u(idx) = [];
