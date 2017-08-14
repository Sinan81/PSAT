function b = subsref(a,index)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'con'
    if length(index) == 2
      b = a.con(index(2).subs{:});
    else
      b = a.con;
    end
   case 'day'
    if length(index) == 2
      b = a.day(index(2).subs{:});
    else
      b = a.day;
    end
   case 'week'
    if length(index) == 2
      b = a.week(index(2).subs{:});
    else
      b = a.week;
    end
   case 'year'
    if length(index) == 2
      b = a.year(index(2).subs{:});
    else
      b = a.year;
    end
   case 'n'
    b = a.n;
   case 'd'
    b = a.d;
   case 'w'
    b = a.w;
   case 'y'
    b = a.y;
   case 'len'
    b = a.len;
   case 'store'
    b = a.store;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
