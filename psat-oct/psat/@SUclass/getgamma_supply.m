function gamma = getgamma_supply(a)

gamma = [];

if ~a.n, return, end

gamma = a.u.*a.con(:,15);
