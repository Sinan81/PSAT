function windup(a)

if ~a.n, return, end

fm_windup(a.vcs,a.con(:,9),a.con(:,10),'td')
