function [a,bus1,bus2,x,y] = factsetup(a,idx,Cp,type)

if ~a.n, return, end
if isempty(idx), return, end

bus1 = a.fr(idx);
bus2 = a.to(idx);
y = a.u(idx)./a.con(idx,9);

% neglect line resistance, charging and tap ratio
jdx = find(Cp);
if ~isempty(Cp)
  a.con(idx(jdx),[8 10 12]) = 0;
  a.con(idx(jdx),11) = 1;
end

switch type
 case 'TCSC'
  x = a.u(idx).*Cp./a.con(idx,9)./(1-Cp);
  a.con(idx,9) = (1-Cp).*a.con(idx,9);
 case {'SSSC','UPFC'}
  x = Cp.*a.con(idx,9);
  a.con(idx,9) = a.con(idx,9) - x;
end
