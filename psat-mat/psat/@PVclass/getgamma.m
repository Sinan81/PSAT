function gamma = getgamma(a)

gamma = 0;
if ~a.n, return, end

gamma = sum(a.u.*a.con(:,10));
