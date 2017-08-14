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
   case 'store'
    if length(index) == 2
      b = a.store(index(2).subs{:});
    else
      b = a.store;
    end
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
