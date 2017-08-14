function windup(a)

if ~a.n, return, end

fm_windup(a.theta_p,999*ones(a.n,1),zeros(a.n,1),'td')
fm_windup(a.iqs,a.con(:,21),a.con(:,22),'td')
fm_windup(a.idc,-a.con(:,24),-a.con(:,23),'td')
