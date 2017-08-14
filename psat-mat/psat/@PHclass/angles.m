function [s12a,c12a] = angles(a)

global DAE

alpha  = DAE.x(a.alpha);
t1 = DAE.y(a.bus1);
t2 = DAE.y(a.bus2);

s12a = sin(t1-t2-alpha);
c12a = cos(t1-t2-alpha);
