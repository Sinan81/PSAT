function ptot = totp_sw(a)

ptot = 0;
if ~a.n, return, end
ptot = sum(a.u.*a.pg);
