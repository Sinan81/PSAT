function ptot = totp_demand(a)

ptot = 0;
if ~a.n, return, end
ptot = sum(a.u.*a.con(:,7));
