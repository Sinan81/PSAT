function [jdx,udx] = getidx(a,idx)

jdx = [];
udx = [];

if ~a.n, return, end
if isempty(idx), return, end

jdx = [a.vp0(idx); a.vq0(idx); a.vref(idx)];

udx = [a.u(idx).*a.con(idx,15); ...
       a.u(idx).*a.con(idx,16); ...
       a.u(idx).*a.con(idx,17)];
