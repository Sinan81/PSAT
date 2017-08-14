function [x,y] = getxy_coi(a,bus,x,y)

if ~a.n, return, end

y = [y; a.delta; a.omega];
