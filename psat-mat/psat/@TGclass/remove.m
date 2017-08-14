function a = remove(a,idx)
% removes one or more instances of the device
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
  end
  jdx = find(a.ty3 == idx(i));
  if jdx 
    a.ty3(jdx) = [];
  end
  jdx = find(a.ty4 == idx(i));
  if jdx 
    a.ty4(jdx) = [];
  end
  jdx = find(a.ty5 == idx(i));
  if jdx 
    a.ty5(jdx) = [];
  end
  jdx = find(a.ty6 == idx(i));
  if jdx 
    a.ty6(jdx) = [];
  end
end

a.con(idx,:) = [];
a.bus(idx) = [];
a.syn(idx) = [];
a.tg1(idx) = [];
a.tg2(idx) = [];
a.tg3(idx) = [];
a.tg4(idx) = [];
a.tg5(idx) = [];
a.tg(idx) = [];
a.pm(idx) = [];
a.wref(idx) = [];
a.u(idx) = [];
a.n = a.n - length(idx);
