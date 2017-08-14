function windup(a)

type = a.con(:,2);
ty2 = find(type == 2);
ty3 = find(type == 3);

vrmax = a.con(:,3);
vrmin = a.con(:,4);

if ty2, fm_windup(a.vr1(ty2),vrmax(ty2),vrmin(ty2),'td'); end
if ty3, fm_windup(a.vf(ty3),vrmax(ty3),vrmin(ty3),'td'); end
