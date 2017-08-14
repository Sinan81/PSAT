function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

type = a.con(idx,4);
a1 = find(type == 1);
a2 = find(type == 2);
a3 = find(type == 3);
a4 = find(type == 4);
a5 = find(type == 5);
a6 = find(type == 6);

a.con(idx,:) = [];
a.n = a.n - length(idx);

if a1, a.svc(a1) = []; end
if a2
  a.tcsc(a2) = [];
  a.kr(a2) = [];
end
if a3, a.statcom(a3) = []; end
if a4, a.sssc(a4) = []; end
if a5
  a.upfc(a5,:) = [];
  a.z(a5,:) = [];
end
if a6, a.dfig(a6) = []; end

a.idx(idx) = [];
a.type(idx) = [];
a.v1(idx) = [];
a.v2(idx) = [];
a.v3(idx) = [];
a.Vs(idx) = [];
a.u(idx) = [];
