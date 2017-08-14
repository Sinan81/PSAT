function windup(a)

if ~a.n, return, end

fm_windup(a.x1,a.con(:,10),a.con(:,11),'td')
