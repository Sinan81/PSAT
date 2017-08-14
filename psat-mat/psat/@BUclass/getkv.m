function out = getkv(a,idx,type)

switch type
 case 1
  out = a.con(idx,2);
 case 2
  out = a.con(idx,2).^2;
 case 0 % all
  out = a.con(:,2);
end
