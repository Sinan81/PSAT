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
   case 'int'
    if length(index) == 2
      b = a.int(index(2).subs{:});
    else
      b = a.int;
    end
   case 'bus'
    if length(index) == 2
      switch index(2).type
       case '{}'
        b = a.bus{index(2).subs{:}};
       case '()'
        b = a.bus(index(2).subs{:});
      end
    else
      b = a.bus;
    end
   case 'names'
    if length(index) == 2
      switch index(2).type
       case '{}'
        b = a.names{index(2).subs{:}};
       case '()'
        b = a.names(index(2).subs{:});
      end
    else
      b = a.names;
    end
   case 'store'
    if length(index) == 2
      b = a.store(index(2).subs{:});
    else
      b = a.store;
    end
   case 'slack'
    if length(index) == 2
      b = a.slack(index(2).subs{:});
    else
      b = a.slack;
    end
   case 'n'
    b = a.n;
   case 'type'
    b = a.type;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
