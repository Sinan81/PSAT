function ptot = totp_pq(a)

ptot = 0;
if ~a.n, return, end
ptot = sum(a.u.*a.con(:,4));
