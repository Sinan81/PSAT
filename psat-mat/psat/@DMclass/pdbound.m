function pd = pdbound(a,pd)

pd = max(pd,a.u.*a.con(:,6));
pd = min(pd,a.u.*a.con(:,5));
