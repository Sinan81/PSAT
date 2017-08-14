function windup(a)

if ~a.n, return, end

fm_windup(a.alpha,a.con(:,13),a.con(:,14),'td')
