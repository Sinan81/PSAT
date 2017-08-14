function [x,y] = getxy(a,bus,x,y)

if ~a.n, return, end

y = [y; a.delta; a.omega];
