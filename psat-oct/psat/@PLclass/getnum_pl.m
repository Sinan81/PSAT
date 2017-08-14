function n = getnum_pl(a)

if a.n
  n = sum(~a.con(:,11).*a.u);
else
  n = 0;
end
