function windup(a)

if ~a.n, return, end

fm_windup(a.m,a.con(:,6),a.con(:,7),'td')
