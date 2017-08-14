function u = getstatus_ind(a)

global DAE

u = (a.con(:,18) <= DAE.t | a.z) & a.u;
