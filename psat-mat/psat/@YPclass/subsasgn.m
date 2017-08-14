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
   case 'day'
    if length(index) == 2
      a.day(index(2).subs{:}) = val;
    else
      a.day = val;
    end
   case 'week'
    if length(index) == 2
      a.week(index(2).subs{:}) = val;
    else
      a.week = val;
    end
   case 'year'
    if length(index) == 2
      a.year(index(2).subs{:}) = val;
    else
      a.year = val;
    end
   case 'n'
    a.n = val;
   case 'd'
    a.d = val;
   case 'w'
    a.w = val;
   case 'y'
    a.y = val;
   case 'len'
    a.len = val;
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
  end
end
