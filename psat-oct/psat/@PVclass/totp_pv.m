function ptot = totp_pv(a)

ptot = 0;
if ~a.n, return, end
ptot = sum(a.u.*a.con(:,4));
