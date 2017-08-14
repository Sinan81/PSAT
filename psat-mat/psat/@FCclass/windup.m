function windup(a)

if ~a.n, return, end

fm_windup(a.m,a.con(:,29),a.con(:,30),'td')
