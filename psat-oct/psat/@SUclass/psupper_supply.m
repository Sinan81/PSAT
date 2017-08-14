function idx = psupper_supply(a,ps)

idx = find(ps > a.u.*a.con(:,4));
