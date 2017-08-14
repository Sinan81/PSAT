function out = getarea(a,idx,type)

if length(a.con(1,:)) <= 4
  switch type
   case 1
    out = ones(length(idx),1);
   case 0
    out = ones(a.n,1);
  end  
else
  switch type
   case 1
    out = a.con(idx,5);
   case 0 % all
    out = a.con(:,5);
  end
end
