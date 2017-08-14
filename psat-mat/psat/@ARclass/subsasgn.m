function a = subsasgn(a,index,val)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'con'
    if length(index) == 2
      a.con(index(2).subs{:}) = val;
    else
      a.con = val;
    end
   case 'int'
    if length(index) == 2
      a.int(index(2).subs{:}) = val;
    else
      a.int = val;
    end
   case 'bus'
    if length(index) == 2
      a.bus(index(2).subs{:}) = val;
    else
      a.bus = val;
    end
   case 'names'
    if length(index) == 2
      a.names(index(2).subs{:}) = val;
    else
      a.names = val;
    end
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
   case 'slack'
    if length(index) == 2
      a.slack(index(2).subs{:}) = val;
    else
      a.slack = val;
    end
  end
end
