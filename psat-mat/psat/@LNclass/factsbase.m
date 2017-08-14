function [x,y] = factsbase(a,idx,Cp,type)

if ~a.n, return, end
if isempty(idx), return, end

switch type
 case 'TCSC'
  x = a.u(idx).*Cp./a.con(idx,9);
 case {'SSSC','UPFC'}
  x = a.con(idx,9).*Cp./(1-Cp);  
end

y = a.u(idx).*(1-Cp)./a.con(idx,9);
