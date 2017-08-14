function u = getstatus(a)

global DAE

u = (a.con(:,18) <= DAE.t | a.z) & a.u;
