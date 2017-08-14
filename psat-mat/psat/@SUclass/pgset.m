function a = pgset(a)

if ~a.n, return, end
a.con(:,3) = a.u.*a.con(:,6);
