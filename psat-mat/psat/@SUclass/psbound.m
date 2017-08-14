function ps = psbound(a,ps)

ps = max(ps,a.u.*a.con(:,5));
ps = min(ps,a.u.*a.con(:,4));
