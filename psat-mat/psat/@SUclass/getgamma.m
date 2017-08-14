function gamma = getgamma(a)

gamma = [];

if ~a.n, return, end

gamma = a.u.*a.con(:,15);
