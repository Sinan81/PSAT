function windup(a)

if ~a.n, return, end

fm_windup(a.x,a.con(:,9),0,'td')
