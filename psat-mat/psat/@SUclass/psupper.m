function idx = psupper(a,ps)

idx = find(ps > a.u.*a.con(:,4));
