function a = pqset(a,tanphi)

if ~a.n, return, end
a.con(:,3) = a.u.*a.con(:,7);
a.con(:,4) = a.u.*a.con(:,7).*tanphi;
